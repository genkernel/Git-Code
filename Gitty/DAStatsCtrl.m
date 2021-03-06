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

@interface DAStatsCtrl ()
@property (strong, nonatomic, readonly) NSDictionary *dataSource;

@property (strong, nonatomic, readonly) DAGitLatestDayStats *latestDayFilter;

@property (strong, nonatomic) NSIndexPath *selectedCommitIndexPath;

@property (strong, nonatomic, readonly) UIToolbar *headerBluringToolbar;
@end

@implementation DAStatsCtrl
@dynamic repoCtrl;
@dynamic commitsTable;
@synthesize isByBranchTableVisible = _isByBranchTableVisible;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.headlineLabel.attributedText = nil;
	
	[self applyLightEffectOnHeader];
	
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
	
	_latestDayFilter = [DAGitLatestDayStats filterShowingLatestDaysOfCount:1];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.selectedCommitIndexPath) {
		NSIndexPath *ip = [self.commitsTable tableIndexPathFromTreePath:self.selectedCommitIndexPath];
		
		[self.commitsTable deselectRowAtIndexPath:ip animated:animated];
		
		_selectedCommitIndexPath = nil;
	}
}

- (void)applyLightEffectOnHeader {
	_headerBluringToolbar = [UIToolbar.alloc initWithFrame:self.blurringBackground.bounds];
	
	self.headerBluringToolbar.translucent = YES;
	self.headerBluringToolbar.barTintColor = UIColor.blackColor;
	
	[self.blurringBackground.layer insertSublayer:self.headerBluringToolbar.layer atIndex:0];
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
