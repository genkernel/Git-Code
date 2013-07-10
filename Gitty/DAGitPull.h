//
//  DAGitPull.h
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitAction.h"
#import "DAGitPullDelegate.h"

@interface DAGitPull : DAGitAction
+ (instancetype)pullForRepository:(GTRepository *)repo fromServer:(DAGitServer *)server;

@property (strong, nonatomic) DAGitPullDelegate *delegate;
@end
