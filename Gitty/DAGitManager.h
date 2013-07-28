//
//  DAGitManager.h
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAServerManager.h"
// Actions (+ its Delegates).
#import "DAGitClone.h"
#import "DAGitPull.h"

typedef void (^GitAction)();

@interface DAGitManager : NSObject
+ (instancetype)manager;

@property (strong, nonatomic, readonly) NSString *repoRootPath;
@property (strong, nonatomic, readonly) UIApplication *app;

- (void)request:(DAGitAction *)action;
- (void)request:(DAGitAction *)action delegateQueue:(dispatch_queue_t)queue;

- (BOOL)isLocalRepoExistent:(NSString *)repoFullName forServer:(DAGitServer *)server;
- (GTRepository *)localRepoWithName:(NSString *)repoFullName forServer:(DAGitServer *)server;

- (void)removeExistingRepo:(NSString *)repoName forServer:(DAGitServer *)server;
- (void)scanAllDeletableLocalReposAndDelete;
@end
