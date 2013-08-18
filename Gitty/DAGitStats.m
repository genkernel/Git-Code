//
//  DAGitStats.m
//  Gitty
//
//  Created by kernel on 17/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitStats.h"

@interface DAGitStats ()
@property (strong, nonatomic, readonly) GTRepository *repo;

@property (strong, nonatomic, readonly) NSOperationQueue *q;
//@property (strong, nonatomic, readonly) GTEnumerator *iter;
//@property (strong, nonatomic, readonly) NSArray *branches, *commits;
@end

@implementation DAGitStats

+ (instancetype)statsForRepository:(GTRepository *)repo {
	DAGitStats *stats = self.new;
	[stats load:repo];
	
	return stats;
}

- (id)init {
	self = [super init];
	if (self) {
		_q = NSOperationQueue.new;
	}
	return self;
}

- (void)load:(GTRepository *)repo {
	_repo = repo;
}

- (void)performSyncOperation:(id<DAGitOperation>)operation {
	[operation perform];
}

- (void)performAsyncOperation:(id<DAGitOperation>)operation completionHandler:(void(^)())handler {
	[self.q addOperationWithBlock:^{
		[operation perform];
	}];
}

/*
	NSArray *branches = [self.repo remoteBranchesWithError:nil];
	
	[Logger info:@"\nBranches: (%d): ", branches.count];
	for (GTBranch *br in branches) {
		[Logger info:@"%@ : %@", br.shortName, br.SHA];
	}
	[Logger info:@"-----"];
	
	_branches = branches;
	
	[self loadAllCommits];
}

- (void)loadAllCommits {
	NSError *err = nil;
	_iter = [GTEnumerator.alloc initWithRepository:self.repo error:&err];
	
	[self.iter resetWithOptions:GTEnumeratorOptionsTimeSort];
	
	[self.iter pushGlob:@"refs/remotes/origin/*" error:&err];
	
	NSArray *commits = [self.iter allObjectsWithError:&err];
	
	[Logger info:@"\nCommits (%d): ", commits.count];
	for (GTCommit *ci in commits) {
		[Logger info:@"0x%X %@ : %@ : %@", ci, ci.shortSHA, ci.SHA, ci.messageSummary];
	}
	[Logger info:@"-----"];
	
	_commits = commits;
}

- (void)performWalkOnBranch:(GTBranch *)branch {
	NSError *err = nil;
	[self.iter pushSHA:branch.SHA error:&err];
	
	NSArray *commits = [self.iter allObjectsWithError:&err];
	
	[Logger info:@"\n %@ br_commits (%d): ", branch.name, commits.count];
	for (GTCommit *ci in commits) {
		[Logger info:@"0x%X %@ : %@ : %@", ci, ci.shortSHA, ci.SHA, ci.messageSummary];
	}
	[Logger info:@"-----"];
}
*/
@end
