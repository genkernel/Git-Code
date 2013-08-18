//
//  DARepoWalk.h
//  Gitty
//
//  Created by kernel on 18/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAGitOperation.h"

@interface DARepoWalk : NSObject <DAGitOperation>
+ (instancetype)walkForRepo:(GTRepository *)repo;

@property (nonatomic, readonly) NSUInteger statsCommitsCount;
// Format: author.name  =>  <NSArray of commits>
@property (strong, nonatomic, readonly) NSDictionary *statsCommitsByAuthor;
// Format: branch.name  =>  <NSArray of commits>
@property (strong, nonatomic, readonly) NSDictionary *statsCommitsByBranch;

// NSArray of GTBranch instances.
@property (strong, nonatomic, readonly) NSArray *heads;
// Format: branch.SHA  =>  <NSArray of commits unique to the branch>
@property (strong, nonatomic, readonly) NSDictionary *headCommits;
// Format: branch.SHA  =>  <GTBranch>
@property (strong, nonatomic, readonly) NSDictionary *headRefs;
@end
