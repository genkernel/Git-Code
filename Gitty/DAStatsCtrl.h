//
//  DAStatsCtrl.h
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DAStatsCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate>
- (void)loadCommitsDataSource:(NSDictionary *)commits;

// Header.
@property (strong, nonatomic) IBOutlet UIView *headerContainer;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *headlineLabel;
@property (strong, nonatomic) IBOutlet UITableView *commitsTable;

@end
