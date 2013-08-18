//
//  DAStatsDataSource.h
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

#import "DACommitCell.h"
#import "DACommitBranchCell.h"
#import "DACommitMessageCell.h"

@class DAStatsDataSource;

typedef void (^CellSelectionBlock)(DAStatsDataSource *, NSIndexPath *);

@interface DAStatsDataSource : NSObject <TreeTableDataSource, UITableViewDelegate> {
	CGFloat headerHeight;
}
@property (weak, nonatomic) DARepoWalk *stats;

@property (weak, nonatomic) NSDictionary *commits;
@property (weak, nonatomic) NSDictionary *authors, *branches;

@property () BOOL shouldIncludeDayNameInTimestamp;
@property (strong, nonatomic) CellSelectionBlock selectCellAction;

- (void)setupForTableView:(UITableView *)tableView;
- (BOOL)treeView:(TreeTable *)proxy toggleCellAtIndexPath:(NSIndexPath *)indexPath treeIndexPath:(NSIndexPath *)ip;

@property (strong, nonatomic, readonly) NSMutableSet *closedItems;

// Helpers.
- (GTCommit *)commitForIndexPath:(NSIndexPath *)indexPath;
@end
