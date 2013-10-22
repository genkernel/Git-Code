//
//  DAStatsCtrl.m
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatsCtrl.h"
#import "DAStatsCtrl+Private.h"
#import "DAStatsCtrl+Animation.h"
#import "DAStatsCtrl+Headline.h"

static const NSUInteger OneDayStats = 1;

@interface DAStatsCtrl ()
@property (strong, nonatomic, readonly) NSDictionary *dataSource;

@property (strong, nonatomic, readonly) DAGitLatestDayStats *latestDayFilter;

@property (strong, nonatomic) NSIndexPath *selectedCommitIndexPath;
@end

@implementation DAStatsCtrl
@dynamic repoCtrl;
@dynamic commitsTable;
@synthesize isByBranchTableVisible = _isByBranchTableVisible;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.byAuthorTable.scrollsToTop = NO;
	self.byBranchTable.scrollsToTop = NO;
	
	self.byAuthorProxy.closingAnimation = UITableViewRowAnimationFade;
	self.byBranchProxy.closingAnimation = UITableViewRowAnimationFade;
	
	[self.byAuthorDataSource setupForTableView:self.byAuthorTable];
	[self.byBranchDataSource setupForTableView:self.byBranchTable];
	
	__weak DAStatsCtrl *ctrl = self;
	CellSelectionBlock select = ^(DAStatsDataSource *dataSource, NSIndexPath *ip){
		ctrl.selectedCommitIndexPath = ip;
		
		GTCommit *commit = [dataSource commitForIndexPath:ip];
		[ctrl.repoCtrl presentDiffCtrlForCommit:commit];
	};
	self.byAuthorDataSource.selectCellAction = select;
	self.byBranchDataSource.selectCellAction = select;
	
	_latestDayFilter = [DAGitLatestDayStats filterShowingLatestDaysOfCount:OneDayStats];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.selectedCommitIndexPath) {
		TreeTable *proxy = (TreeTable *)self.commitsTable.dataSource;
		NSIndexPath *ip = [proxy tableIndexPathFromTreePath:self.selectedCommitIndexPath];
		
		[self.commitsTable deselectRowAtIndexPath:ip animated:animated];
		
		_selectedCommitIndexPath = nil;
	}
}

- (void)reloadStatsData:(DARepoWalk *)stats {
	_repoStats = stats;
	
	_lastDayStats = (DARepoWalk *)[stats filter:self.latestDayFilter];
	
	self.byAuthorDataSource.stats = self.lastDayStats;
	self.byBranchDataSource.stats = self.lastDayStats;
	
	[self.byAuthorTable reloadData];
	[self.byBranchTable reloadData];
	
	[self reloadStatusView];
	[self loadStatsHeadline];
}

- (void)reloadStatusView {
	BOOL hasNoCommitsToShow = 0 == self.lastDayStats.allCommits.count;
	
	self.commitsContainer.hidden = hasNoCommitsToShow;
	self.noCommitsLabel.hidden = !hasNoCommitsToShow;
}

#pragma mark Properties

- (DARepoCtrl *)repoCtrl {
	return (DARepoCtrl *)self.parentViewController;
}

- (UITableView *)commitsTable {
	return self.isByBranchTableVisible ? self.byBranchTable : self.byAuthorTable;
}

@end
