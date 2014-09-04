//
//  DAGitOperation.h
//  Gitty
//
//  Created by kernel on 18/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAGitOperationFilter.h"

@protocol DAGitOperation <NSObject>
@required
- (void)perform;
- (id<DAGitOperation>)filter:(id<DAGitOperationFilter>)filter;

@property (nonatomic, readonly) BOOL hasMoreCommitsToProcess;

@optional
@property (strong, nonatomic) id<DAGitOperationFilter> filter;
@end
