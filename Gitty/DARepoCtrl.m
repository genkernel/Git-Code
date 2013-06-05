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
#import "DABranchPickerCtrl.h"
// Cells.
#import "DABranchCell.h"
#import "DACommitCell.h"

static NSString *MasterBranchName = @"master";

static NSString *BranchPickerSegue = @"BranchPickerSegue";
static NSString *DiffSegue = @"DiffSegue";

@interface DARepoCtrl ()
@property (strong, nonatomic, readonly) NSArray *remoteBranches/*, *localBranches*/;
@property (strong, nonatomic, readonly) NSDictionary *namedBranches;

@property (strong, nonatomic, readonly) GTBranch *currentBranch;
@property (strong, nonatomic, readonly) NSArray *commits;

@property (strong, nonatomic, readonly) DABranchPickerCtrl *branchPickerCtrl;
@end

@implementation DARepoCtrl

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
		
		NSIndexPath *ip = sender;
		BOOL isFirstCommit = ip.row == self.commits.count - 1;
		
//		NSUInteger idx = self.commits.count - ip.row - 1;
		
		if (isFirstCommit) {
			NSAssert(NO, @"First commit diff.");
		} else {
			ctrl.changeCommit = self.commits[ip.row];
			ctrl.previousCommit = self.commits[ip.row + 1];
		}
	} else {
		[super prepareForSegue:segue sender:sender];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UINib *nib = [UINib nibWithNibName:DACommitCell.className bundle:nil];
	[self.commitsTable registerNib:nib forCellReuseIdentifier:DACommitCell.className];
	
	[self updateFilters];
	[self reloadCommits];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)updateFilters {
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
		NSDate *date = nil;
		_commits = [self loadCommitsInBranch:self.currentBranch betweenNowAndDate:date];
	}
	double period = [NSObject endMeasurement];
	[Logger info:@"%d commits loaded in %.2f.", self.commits.count, period];
	
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
	
	[self.currentBranchButton setTitle:self.currentBranch.name.lastPathComponent forState:UIControlStateNormal];
	
	return YES;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.commits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GTCommit *commit = self.commits[indexPath.row];
	
	DACommitCell *cell = [tableView dequeueReusableCellWithIdentifier:DACommitCell.className];
	
	[cell loadCommit:commit];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self performSegueWithIdentifier:DiffSegue sender:indexPath];
}

#pragma mark Actions

- (IBAction)selectBranchPressed:(UIButton *)sender {
	self.branchPickerCtrl.branches = self.remoteBranches;
	[self.branchPickerCtrl.picker reloadAllComponents];
	
	NSUInteger row = [self.remoteBranches indexOfObject:self.currentBranch];
	[self.branchPickerCtrl.picker selectRow:row inComponent:0 animated:NO];
	
	[self setBranchOverlayVisible:YES animated:YES];
}

@end
