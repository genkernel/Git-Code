//
//  DAReposListCtrl.h
//  Gitty
//
//  Created by kernel on 1/10/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DAReposListCtrl : DABaseCtrl
@property (strong, nonatomic) DAGitServer *server;

@property (strong, nonatomic) void (^showServersAction)();
@property (strong, nonatomic) void (^cancelAction)();
@property (strong, nonatomic) void (^selectAction)(NSDictionary *repo);

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) IBOutlet UIButton *serversButton;
@end
