//
//  DAStatsDataSource.h
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@class DAStatsCtrl;
@class DAStatsDataSource;

typedef void (^CellSelectionBlock)(DAStatsDataSource *, NSIndexPath *);

@interface DAStatsDataSource : DABaseCtrl/*using ctrl for cachedViews support*/ <UITableViewDataSource, UITableViewDelegate> {
	CGFloat headerHeight;
}
@property (weak, nonatomic) NSDictionary *commits;
@property (weak, nonatomic) NSDictionary *authors, *branches;

@property () BOOL shouldIncludeDayNameInTimestamp;
@property (strong, nonatomic) CellSelectionBlock selectCellAction;

// Helpers.
- (GTCommit *)commitForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isSubsequentCommitAtIndexPath:(NSIndexPath *)indexPath;
@end
