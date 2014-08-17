//
//  DAGitStats.h
//  Gitty
//
//  Created by kernel on 17/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchStats.h"

// Operations
#import "DARepoWalk.h"
#import "DABranchWalk.h"
// Filters
#import "DAGitLatestDayStats.h"

@interface DAGitStats : NSObject
+ (instancetype)statsForRepository:(GTRepository *)repo;

//- (void)performSyncOperation:(id<DAGitOperation>)operation;
- (void)performAsyncOperation:(id<DAGitOperation>)operation completionHandler:(void(^)())handler;
@end
