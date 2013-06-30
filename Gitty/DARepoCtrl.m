//
//  DARepoCtrl.m
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl.h"
#import "DARepoCtrl+Animation.h"
#import "DARepoCtrl+GitFetcher.h"
#import "DADiffCtrl.h"
// Filter pickers.
#import "DABranchPickerCtrl.h"
#import "DAPeriodPicker.h"
// Cells.
#import "DABranchCell.h"
#import "DACommitCell.h"

static NSString *MasterBranchName = @"master";

static NSString *DiffSegue = @"DiffSegue";
static NSString *BranchPickerSegue = @"BranchPickerSegue";
static NSString *PeriodPickerSegue = @"PeriodPickerSegue";

@interface DARepoCtrl ()
@property (strong, nonatomic, readonly) NSArray *remoteBranches/*, *localBranches*/;
@property (strong, nonatomic, readonly) NSDictionary *namedBranches;

@property (strong, nonatomic, readonly) GTBranch *currentBranch;
@property (strong, nonatomic, readonly) NSDictionary *commitsOnDateSection;
@property (strong, nonatomic, readonly) NSDictionary *authorsOnDateSection;
@property (strong, nonatomic, readonly) NSArray *dateSections;

@property (strong, nonatomic) DAPeriod *periodFilter;

@property (strong, nonatomic, readonly) NSIndexPath *selectedCommitIndexPath;

@property (strong, nonatomic, readonly) DABranchPickerCtrl *branchPickerCtrl;
@property (strong, nonatomic, readonly) DAPeriodPicker *periodPickerCtrl;
@end

@implementation DARepoCtrl
@synthesize commitsOnDateSection = _commitsOnDateSection;
@synthesize authorsOnDateSection = _authorsOnDateSection;
@synthesize dateSections = _dateSections;

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
	} else if ([segue.identifier isEqualToString:PeriodPickerSegue]) {
		_periodPickerCtrl = segue.destinationViewController;
		
		__weak DARepoCtrl *ref = self;
		self.periodPickerCtrl.cancelBlock = ^{
			[ref setPeriodOverlayVisible:NO animated:YES];
		};
		self.periodPickerCtrl.completionBlock = ^(DAPeriod *period){
			[ref setPeriodOverlayVisible:NO animated:YES];

			BOOL changed = ref.periodFilter != period;
			if (changed) {
				ref.periodFilter = period;
				
				[ref reloadCommits];
			}
		};
	} else if ([segue.identifier isEqualToString:DiffSegue]) {
		DADiffCtrl *ctrl = segue.destinationViewController;
		ctrl.diff = sender;
	} else {
		[super prepareForSegue:segue sender:sender];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UINib *nib = [UINib nibWithNibName:DACommitCell.className bundle:nil];
	[self.commitsTable registerNib:nib forCellReuseIdentifier:DACommitCell.className];
	
	[self.toggleFiltersButton applyGreenStyle];
	
	[self reloadFilters];
	[self reloadCommits];
	
	if (!self.shouldPull) {
		[self setPullingViewVisible:NO animated:NO];
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

- (void)reloadFilters {
	[self updateBranchesFilter];
}

- (void)updateBranchesFilter {
	NSError *err = nil;
	
	[NSObject startMeasurement];
	{
		//_localBranches = [self.currentRepo localBranchesWithError:&err];
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
		[self loadCommitsInBranch:self.currentBranch betweenNowAndDate:self.periodFilter.date];
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
/*
#pragma mark UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.remoteBranches.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	GTBranch *branch = self.remoteBranches[indexPath.row];
	
	DABranchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DABranchCell.className forIndexPath:indexPath];
	
	cell.nameLabel.text = branch.name.lastPathComponent;
	[Logger info:@"branchCell: %@", branch.name];
	
	return cell;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *title = self.dateSections[indexPath.section];
	NSArray *commits = self.commitsOnDateSection[title];
	
	GTCommit *commit = commits[indexPath.row];
	
	DACommitCell *cell = [tableView dequeueReusableCellWithIdentifier:DACommitCell.className];
	
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
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSegueWithIdentifier:DiffSegue sender:diff];
		});
	});
}

#pragma mark Actions

- (IBAction)toggleFiltersPressed:(UIButton *)sender {
	isFiltersContainerVisible = !isFiltersContainerVisible;
	[self setFiltersViewVisible:isFiltersContainerVisible animated:YES];
}

- (IBAction)selectBranchPressed:(UIButton *)sender {
	// Reload as new branches were pulled in (possibly).
	self.branchPickerCtrl.branches = self.remoteBranches;
	[self.branchPickerCtrl.picker reloadAllComponents];
	
	// Selects default branch (master) on first use.
	NSUInteger row = [self.remoteBranches indexOfObject:self.currentBranch];
	[self.branchPickerCtrl.picker selectRow:row inComponent:0 animated:NO];
	
	[self setBranchOverlayVisible:YES animated:YES];
}

- (IBAction)selectPeriodPressed:(UIButton *)sender {
	// Select previously activated period (if row was changed but canceled).
	[self.periodPickerCtrl selectPeriodItem:self.periodFilter animated:NO];
	
	[self setPeriodOverlayVisible:YES animated:YES];
}

#pragma mark Properties

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
