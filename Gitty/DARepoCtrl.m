//
//  DARepoCtrl.m
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl.h"
#import "DARepoCtrl+Private.h"
#import "DARepoCtrl+Animation.h"
#import "DARepoCtrl+GitFetcher.h"
#import "DARepoCtrl+StatsLoader.h"
// Filter pickers.
#import "DABranchPickerCtrl.h"
// Cells.
#import "DACommitCell.h"
#import "DACommitMessageCell.h"

static NSString *MasterBranchName = @"master";

static NSString *DiffSegue = @"DiffSegue";
static NSString *StatsSegue = @"StatsSegue";
static NSString *BranchPickerSegue = @"BranchPickerSegue";

static const CGFloat StatsContainerMinDraggingOffsetToSwitchState = 100.;

@interface DARepoCtrl ()
@property (strong, nonatomic, readonly) GTBranch *currentBranch;
@property (strong, nonatomic, readonly) NSDictionary *commitsOnDateSection;
@property (strong, nonatomic, readonly) NSDictionary *authorsOnDateSection;
@property (strong, nonatomic, readonly) NSArray *dateSections;

// Format: author.name  =>  <NSArray of commits>
@property (strong, nonatomic, readonly) NSMutableDictionary *statsCommitsByAuthor;
// Format: branch.name  =>  <NSArray of commits>
@property (strong, nonatomic, readonly) NSMutableDictionary *statsCommitsByBranch;

@property (strong, nonatomic, readonly) NSIndexPath *selectedCommitIndexPath;

@property (strong, nonatomic, readonly) DAStatsCtrl *statsCtrl;
@property (strong, nonatomic, readonly) DABranchPickerCtrl *branchPickerCtrl;

@property (strong, nonatomic, readonly) DACommitCell *reuseCell;
@property (strong, nonatomic, readonly) DACommitMessageCell *reuseSimpleCell;
@end

@implementation DARepoCtrl {
	NSUInteger forgetActionTag;
	CGFloat statsContainerOffsetBeforeDragging;
	NSArray *_remoteBranches;
}
@synthesize commitsOnDateSection = _commitsOnDateSection;
@synthesize authorsOnDateSection = _authorsOnDateSection;
@synthesize dateSections = _dateSections;
@synthesize statsCtrl = _statsCtrl;
@synthesize statsCommitsByAuthor = _statsCommitsByAuthor;
@synthesize statsCommitsByBranch = _statsCommitsByBranch;
// Category-defined ivars synthesized explicitly.
@synthesize remoteBranches = _remoteBranches;
@synthesize namedBranches;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:BranchPickerSegue]) {
		_branchPickerCtrl = segue.destinationViewController;
		
		__weak DARepoCtrl *ref = self;
		self.branchPickerCtrl.completionBlock = ^(GTBranch *selectedBranch){
			[ref setBranchOverlayVisible:NO animated:YES];
			
			BOOL changed = [ref selectBranch:selectedBranch];
			if (changed) {
				[ref reloadCommits];
			}
		};
	} else if ([segue.identifier isEqualToString:DiffSegue]) {
		DADiffCtrl *ctrl = segue.destinationViewController;
		ctrl.diff = sender;
	} else if ([segue.identifier isEqualToString:StatsSegue]) {
		_statsCtrl = segue.destinationViewController;
	} else {
		[super prepareForSegue:segue sender:sender];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	{
		UINib *nib = [UINib nibWithNibName:DACommitCell.className bundle:nil];
		[self.commitsTable registerNib:nib forCellReuseIdentifier:DACommitCell.className];
		
		_reuseCell = [self.commitsTable dequeueReusableCellWithIdentifier:DACommitCell.className];
	}
	{
		UINib *nib = [UINib nibWithNibName:DACommitMessageCell.className bundle:nil];
		[self.commitsTable registerNib:nib forCellReuseIdentifier:DACommitMessageCell.className];
		
		_reuseSimpleCell = [self.commitsTable dequeueReusableCellWithIdentifier:DACommitMessageCell.className];
	}
	
	self.revealBranchOverlayButton.layer.cornerRadius = 7.;
	self.revealBranchOverlayButton.layer.masksToBounds = YES;
	
	[self reloadFilters];
	[self reloadCommits];
	
	if (!self.shouldPull) {
		[self loadStats];
	} else {
		[self pull];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.selectedCommitIndexPath) {
		[self.commitsTable deselectRowAtIndexPath:self.selectedCommitIndexPath animated:animated];
		
		_selectedCommitIndexPath = nil;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self setDiffLoadingOverlayVisible:NO animated:NO];
}

- (void)addForgetButton {
	UIButton *forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[forgetButton setImage:[UIImage imageNamed:@"repo-forget.png"] forState:UIControlStateNormal];
	[forgetButton sizeToFit];
	
	[forgetButton addTarget:self action:@selector(forgetPressed) forControlEvents:UIControlEventTouchUpInside];
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:forgetButton];
}

- (void)reloadFilters {
	[self updateBranchesFilter];
}

- (void)updateBranchesFilter {
	NSError *err = nil;
	
	[NSObject startMeasurement];
	{
		_remoteBranches = [self.currentRepo remoteBranchesWithError:&err];
	}
	double period = [NSObject endMeasurement];
	
	[Logger info:@"Branches: %d. Counted in %.2f", /*self.localBranches.count, */self.remoteBranches.count, period];
	
	GTBranch *defaultBranch = nil;
	
	NSMutableDictionary *branches = [NSMutableDictionary dictionaryWithCapacity:self.remoteBranches.count];
	for (GTBranch *branch in self.remoteBranches) {
		NSString *name = branch.name.lastPathComponent;
		branches[name] = branch;
		
		if ([name isEqualToString:MasterBranchName]) {
			defaultBranch = branch;
		}
	}
	
	if (!defaultBranch) {
		defaultBranch = self.remoteBranches.anyObject;
	}
	[self selectBranch:defaultBranch];
}

- (void)reloadCommits {
	[NSObject startMeasurement];
	{
		[self loadCommitsInBranch:self.currentBranch];
	}
	double period = [NSObject endMeasurement];
	[Logger info:@"Commits of %d days loaded in %.2f.", self.dateSections.count, period];
	
	[self.commitsTable reloadData];
}

/*
- (GTBranch *)trackingLocalBranchForRemoteBranch:(GTBranch *)branch {
	
}

- (BOOL)isBranchTrackedLocally:(GTBranch *)branch {
	if (GTBranchTypeLocal == branch.branchType) {
		return YES;
	}
	
	NSString *branchName = branch.name.lastPathComponent;
	
	for (GTBranch *localBranch in self.localBranches) {
		NSString *name = localBranch.name.lastPathComponent;
		if ([name isEqualToString:branchName]) {
			return YES;
		}
	}
	return NO;
}*/

- (BOOL)selectBranch:(GTBranch *)branch {
	if (!branch || self.currentBranch == branch) {
		return NO;
	}
	
	_currentBranch = branch;
	
	self.title = branch.shortName;
	[self.currentBranchButton setTitle:self.currentBranch.name.lastPathComponent forState:UIControlStateNormal];
	
	return YES;
}

- (void)forgetRepo {
	[self.navigationController popViewControllerAnimated:YES];
	
	[self.git removeExistingRepo:self.repoServer.recentRepoPath forServer:self.repoServer];
}

#pragma mark UITableViewDataSource helpers

- (GTCommit *)commitForIndexPath:(NSIndexPath *)indexPath {
	NSString *title = self.dateSections[indexPath.section];
	NSArray *commits = self.commitsOnDateSection[title];
	
	return commits[indexPath.row];
}

// Commit is Subsequent when its previous commit is prepared by the same Author in the very same Day.
- (BOOL)isSubsequentCommitAtIndexPath:(NSIndexPath *)indexPath {
	NSString *title = self.dateSections[indexPath.section];
	NSArray *commits = self.commitsOnDateSection[title];
	
	NSUInteger idx = indexPath.row;
	GTCommit *commit = commits[idx];
	
	BOOL previousCommitHasSameAuthor = NO;
	
	BOOL hasPreviousCommitInSection = idx > 0;
	if (hasPreviousCommitInSection) {
		GTCommit *prevCommit = commits[idx - 1];
		
		previousCommitHasSameAuthor = [commit.author.name isEqualToString:prevCommit.author.name] && [commit.author.email isEqualToString:prevCommit.author.email];
	}
	
	return previousCommitHasSameAuthor;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.dateSections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.dateSections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *title = self.dateSections[section];
	NSArray *commits = self.commitsOnDateSection[title];
	
	return commits.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:indexPath];
	
	DACommitMessageCell *cell = previousCommitHasSameAuthor ? self.reuseSimpleCell : self.reuseCell;
	
	GTCommit *commit = [self commitForIndexPath:indexPath];
	return [cell heightForCommit:commit];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GTCommit *commit = [self commitForIndexPath:indexPath];
	
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:indexPath];
	Class cls = previousCommitHasSameAuthor ? DACommitMessageCell.class : DACommitCell.class;
	
	DACommitCell *cell = [tableView dequeueReusableCellWithIdentifier:cls.className];
	
	[cell loadCommit:commit];
	[cell setShowsTopCellSeparator:indexPath.row > 0];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_selectedCommitIndexPath = indexPath;
	
	NSString *title = self.dateSections[indexPath.section];
	NSArray *commits = self.commitsOnDateSection[title];
	
	GTCommit *commit = commits[indexPath.row];
	[self presentDiffCtrlForCommit:commit];
}

- (void)presentDiffCtrlForCommit:(GTCommit *)commit {
	if (!commit.isLargeCommit) {
		DADiffCtrlDataSource *diff = [DADiffCtrlDataSource loadDiffForCommit:commit];
		
		[self performSegueWithIdentifier:DiffSegue sender:diff];
		return;
	}
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		[self setDiffLoadingOverlayVisible:YES animated:NO];
	}completion:^(BOOL finished) {
		[self prepareDiffForCommit:commit];
	}];
}

- (void)prepareDiffForCommit:(GTCommit *)commit {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		DADiffCtrlDataSource *diff = [DADiffCtrlDataSource loadDiffForCommit:commit];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSegueWithIdentifier:DiffSegue sender:diff];
		});
	});
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == forgetActionTag) {
		
		if (1 == buttonIndex) {
			[self forgetRepo];
		}
	}
}

#pragma mark Actions

- (IBAction)revealBranchPressed:(UIButton *)sender {
	// Reload as new branches were pulled in (possibly).
	self.branchPickerCtrl.branches = self.remoteBranches;
	[self.branchPickerCtrl.picker reloadAllComponents];
	
	// Selects default branch (master) on first use.
	NSUInteger row = [self.remoteBranches indexOfObject:self.currentBranch];
	[self.branchPickerCtrl.picker selectRow:row inComponent:0 animated:NO];
	
	[self setBranchOverlayVisible:YES animated:YES];
}

- (void)forgetPressed {
	NSString *title = NSLocalizedString(@"Forget repo", nil);
	NSString *message = NSLocalizedString(@"Forgetting this repo will delete all its fetched data from disk.", nil);
	
	forgetActionTag = [self showYesNoMessage:message withTitle:title];
}

- (IBAction)statsDidClick:(UIButton *)sender {
	statsContainerOffsetBeforeDragging = .0;
	
	[self toggleStatsContainerMode];
}

- (void)toggleStatsContainerMode {
	DAStatsContainerModes mode = DAStatsFullscreenMode == statsContainerMode ? DAStatsHiddenMode : DAStatsFullscreenMode;
	[self setStatsContainerMode:mode animated:YES];
}

- (IBAction)statsDidDrag:(UIPanGestureRecognizer *)gr {
	CGPoint p = [gr translationInView:self.view];
	
	if (UIGestureRecognizerStateBegan == gr.state) {
		statsContainerOffsetBeforeDragging = self.mainContainer.y;
	} else if (UIGestureRecognizerStateChanged == gr.state) {
		CGFloat y = statsContainerOffsetBeforeDragging + p.y;
		
		if (y >= .0 && y <= self.view.height) {
			self.mainContainer.y = y;
		}
	} else if (UIGestureRecognizerStateEnded == gr.state) {
		if (DAStatsHeadlineMode == statsContainerMode) {
			statsContainerOffsetBeforeDragging = .0;
			
			DAStatsContainerModes mode = p.y > .0 ? DAStatsFullscreenMode : DAStatsHiddenMode;
			[self setStatsContainerMode:mode animated:YES];
			
			return;
		}
		
		CGFloat offset = fabsf(p.y);
		
		if (offset >= StatsContainerMinDraggingOffsetToSwitchState) {
			[self toggleStatsContainerMode];
		} else {
			// Decelerate back to original position (before dragging).
			[UIView animateWithDuration:StandartAnimationDuration animations:^{
				self.mainContainer.y = statsContainerOffsetBeforeDragging;
			}];
		}
	}
}

#pragma mark Properties

- (NSDateFormatter *)dateSectionTitleFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.dateFormat = @"EEEE, MMMM d, yyyy";
	});
	return formatter;
}

@end
