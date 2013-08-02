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

#import "DAStatsCtrl+Animation.h"

// Cells.
#import "DACommitCell.h"
#import "DACommitMessageCell.h"

#import "DATitleHeader.h"


static NSString *MasterBranchName = @"master";

static NSString *DiffSegue = @"DiffSegue";
static NSString *StatsSegue = @"StatsSegue";
static NSString *BranchPickerSegue = @"BranchPickerSegue";

static const CGFloat StatsContainerMinDraggingOffsetToSwitchState = 100.;
static const CGFloat BranchOverlyMinDraggingOffsetToSwitchState = 100.;

@interface DARepoCtrl ()
@property (strong, nonatomic, readonly) GTBranch *currentBranch;
@property (strong, nonatomic, readonly) NSDictionary *commitsOnDateSection;
@property (strong, nonatomic, readonly) NSDictionary *authorsOnDateSection;
@property (strong, nonatomic, readonly) NSArray *dateSections;

@property (strong, nonatomic, readonly) NSIndexPath *selectedCommitIndexPath;

@property (strong, nonatomic, readonly) DAStatsCtrl *statsCtrl;
@property (strong, nonatomic, readonly) UIButton *statsSelectedModeButton;

@property (strong, nonatomic, readonly) DACommitCell *reuseCell;
@property (strong, nonatomic, readonly) DACommitMessageCell *reuseSimpleCell;
@end

@implementation DARepoCtrl {
	NSUInteger forgetActionTag;
	CGFloat statsContainerOffsetBeforeDragging;
	CGFloat branchContainerOffsetBeforeDragging;
	NSArray *_remoteBranches;
	CGFloat headerHeight;
}
@synthesize authors = _authors, branches = _branches;
@synthesize currentBranch = _currentBranch;
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
				
				[DAFlurry logWorkflowAction:WorkflowActionBranchSwitched];
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
	
	UIImage *img = [UIImage imageNamed:@"branch-selector.png"];
	img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, img.size.height - 100, 0)];
	[self.revealBranchOverlayButton setBackgroundImage:img forState:UIControlStateNormal];
	
	_statsSelectedModeButton = self.statsSwitchModeButtons[0];
	
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
	
	{
		DATitleHeader *header = DATitleHeader.new;
		headerHeight = header.height;
		[self cacheView:header withIdentifier:DATitleHeader.className];
	}
	
	_authors = NSMutableDictionary.new;
	_branches = NSMutableDictionary.new;
	
	[self reloadFilters];
	[self reloadCommits];
	
	if (!self.shouldPull) {
		[self loadStats];
	} else {
		[self pull];
	}
	
	// Initial loading. Required as of long-time pulling + open via swipe case.
	[self.branchPickerCtrl resetWithBranches:self.remoteBranches];
	
	// FIXME: come up with better solution.
	dispatch_async(dispatch_get_main_queue(), ^{
		self.mainContainerHeight.constant = self.view.height - self.mainContainerTop.constant;
		[self.mainContainer.superview layoutIfNeeded];
	});
	
	[DAFlurry logProtocol:self.repoServer.transferProtocol];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[DAFlurry logScreenAppear:self.className];
	
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[DAFlurry logScreenDisappear:self.className];
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
	self.navigationItem.titleView = self.branchCustomTitleContainer;
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.forgetButton];
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
	NSString *recentBranchName = self.repoServer.recentBranchName;
	
	NSMutableDictionary *branches = [NSMutableDictionary dictionaryWithCapacity:self.remoteBranches.count];
	for (GTBranch *branch in self.remoteBranches) {
		NSString *name = branch.shortName;
		branches[name] = branch;
		
		if ([name isEqualToString:recentBranchName]) {
			defaultBranch = branch;
		}
	}
	
	if (!defaultBranch) {
		defaultBranch = branches[MasterBranchName];
		if (!defaultBranch) {
			defaultBranch = self.remoteBranches.anyObject;
		}
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
	
	NSString *branchName = branch.shortName;
	
	for (GTBranch *localBranch in self.localBranches) {
		NSString *name = localBranch.shortName;
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
	
	self.repoServer.recentBranchName = branch.shortName;
	[self.servers save];
	
	self.branchCustomTitleLabel.text = branch.shortName;
	
	return YES;
}

- (void)forgetRepo {
	[self.navigationController popViewControllerAnimated:YES];
	
	[self.git removeExistingRepo:self.repoServer.recentRepoPath forServer:self.repoServer];
	
	[DAFlurry logWorkflowAction:WorkflowActionRepoForgotten];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	DATitleHeader *header = (DATitleHeader *)[self cachedViewWithIdentifier:DATitleHeader.className];
	if (!header) {
		header = DATitleHeader.new;
		header.nameLabel.textColor = UIColor.acceptingGreenColor;
	}
	
	header.nameLabel.text = self.dateSections[section];
	
	return header;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
	[self cacheView:view withIdentifier:view.className];
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
	
	UITableViewCell<DADynamicCommitCell> *cell = [tableView dequeueReusableCellWithIdentifier:cls.className];
	
	[cell setShowsDayName:NO];
	[cell setShowsTopCellSeparator:indexPath.row > 0];
	
	[cell loadCommit:commit];
	
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
		
		[DAFlurry logGitAction:GitActionDiff];
		
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
	BOOL shouldRevealOverlay = !isBranchOverlayVisible;
	if (shouldRevealOverlay) {
		// Reload as new branches were pulled in (possibly).
		[self.branchPickerCtrl resetWithBranches:self.remoteBranches];
	}
	
	[self setBranchOverlayVisible:shouldRevealOverlay animated:YES];
	
	[DAFlurry logWorkflowAction:WorkflowActionBranchListTouch];
}

- (IBAction)forgetPressed:(UIButton *)button {
	NSString *title = NSLocalizedString(@"Forget repo", nil);
	NSString *message = NSLocalizedString(@"Forgetting this repo will delete all its fetched data from disk.", nil);
	
	forgetActionTag = [self showYesNoMessage:message withTitle:title];
}

- (IBAction)statsModeChanged:(UIButton *)sender {
	self.statsSelectedModeButton.enabled = YES;
	_statsSelectedModeButton = sender;
	self.statsSelectedModeButton.enabled = NO;
	
	[self.statsCtrl toggleCommitsTablesAnimated:YES];
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
		statsContainerOffsetBeforeDragging = self.mainContainerTop.constant;
	} else if (UIGestureRecognizerStateChanged == gr.state) {
		CGFloat y = statsContainerOffsetBeforeDragging + p.y;
		
		if (y >= .0 && y <= self.view.height) {
			self.mainContainerTop.constant = y;
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
			self.mainContainerTop.constant = statsContainerOffsetBeforeDragging;
			
			[UIView animateWithDuration:StandartAnimationDuration animations:^{
				[self.mainContainer.superview layoutIfNeeded];
			}];
		}
	}
}

- (void)toggleBranchOverlayMode {
	[self setBranchOverlayVisible:!isBranchOverlayVisible animated:YES];
}

- (IBAction)branchDidDrag:(UIPanGestureRecognizer *)gr {
	CGPoint p = [gr translationInView:self.view];
	
	if (UIGestureRecognizerStateBegan == gr.state) {
		branchContainerOffsetBeforeDragging = self.branchOverlayLeft.constant;
		
	} else if (UIGestureRecognizerStateChanged == gr.state) {
		CGFloat x = branchContainerOffsetBeforeDragging + p.x;
		
		if (x >= .0 && x < self.view.width) {
			self.branchOverlayLeft.constant = x;
		}
		
	} else if (UIGestureRecognizerStateEnded == gr.state) {
		CGFloat offset = fabsf(p.x);
		
		if (offset >= BranchOverlyMinDraggingOffsetToSwitchState) {
			[self toggleBranchOverlayMode];
			[DAFlurry logWorkflowAction:WorkflowActionBranchListDrag];
		} else {
			// Decelerate back to original position (before dragging).
			self.branchOverlayLeft.constant = branchContainerOffsetBeforeDragging;
			
			[UIView animateWithDuration:StandartAnimationDuration animations:^{
				[self.branchOverlay.superview layoutIfNeeded];
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
		formatter.dateFormat = @"EEEE, d MMM, yyyy";
	});
	return formatter;
}

@end
