//
//  DARecentReposCtrl.h
//  Gitty
//
//  Created by kernel on 21/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DARecentReposCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) DAGitServer *server;

@property (strong, nonatomic) void (^cancelAction)();
@property (strong, nonatomic) void (^selectAction)(DAGitRepo *repo);

@property (strong, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) IBOutlet UITableView *reposTable;
@property (strong, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
@property (strong, nonatomic) IBOutlet UIImageView *customLogo;
@end
