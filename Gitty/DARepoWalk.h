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

- (GTSignature *)authorForCommit:(GTCommit *)commit;

@property (strong, nonatomic, readonly) NSArray *allCommits;

// Format: <NSString commit.SHA> => <NSString head.SHA>
@property (strong, nonatomic, readonly) NSDictionary *commitToBranchMap;
// Format: <NSString commit.SHA> => <NSString author.email>
@property (strong, nonatomic, readonly) NSDictionary *commitToAuthorMap;

// Authors info:
// NSArray of GTSignature's emails.
@property (strong, nonatomic, readonly) NSArray *authors;
// Format: author.email  =>  <NSArray of commits>
@property (strong, nonatomic, readonly) NSDictionary *authorCommits;
// Format: author.email  =>  <GTSignature>
@property (strong, nonatomic, readonly) NSDictionary *authorRefs;

// Branches info:
// NSArray of GTBranch's SHAs.
@property (strong, nonatomic, readonly) NSArray *heads;
// Format: branch.SHA  =>  <NSArray of commits unique to the branch>
@property (strong, nonatomic, readonly) NSDictionary *headCommits;
// Format: branch.SHA  =>  <GTBranch>
@property (strong, nonatomic, readonly) NSDictionary *headRefs;
@end
