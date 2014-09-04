//
//  DAGitLatestCommitStats.h
//  Git Code
//
//  Created by Altukhov Anton on 9/4/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DAGitOperationBaseFilter.h"

@interface DAGitLatestCommitStats : DAGitOperationBaseFilter
+ (instancetype)filterShowingLatestCommitsOfCount:(NSUInteger)count;

@property (nonatomic) NSUInteger latestCommitsCount;
@end
