//
//  DAStatsCtrl.h
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

typedef enum {
	DACommitsListByAuthorMode,
	DACommitsListByBranchMode
} DACommitsListModes;

@interface DAStatsCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate>
- (void)loadCommitsDataSource:(NSDictionary *)commits withListMode:(DACommitsListModes)mode;

@property () BOOL isShowingCommitsOfMultipleDays;
@property (readonly) DACommitsListModes listMode;

// Header.
@property (strong, nonatomic) IBOutlet UIView *headerContainer;
@property (strong, nonatomic) IBOutlet UITableView *commitsTable;
@property (strong, nonatomic) IBOutlet UILabel *headlineLabel, *noCommitsLabel;
@end
