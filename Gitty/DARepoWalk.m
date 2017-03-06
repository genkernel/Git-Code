//
//  DARepoWalk.m
//  Gitty
//
//  Created by kernel on 18/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DARepoWalk.h"

@interface DARepoWalk ()
@property (strong, nonatomic) GTRepository *repo;

// (Creation).
@property (strong, nonatomic, readwrite) NSDictionary *commitToBranchMap;
@property (strong, nonatomic, readwrite) NSDictionary *commitToAuthorMap;

@property (strong, nonatomic, readwrite) NSArray *allCommits;
@property (strong, nonatomic, readwrite) NSDictionary *authorCommits;
@property (strong, nonatomic, readwrite) NSDictionary *authorRefs;
@property (strong, nonatomic, readwrite) NSDictionary *headCommits;
@property (strong, nonatomic, readwrite) NSDictionary *headRefs;
@end

@implementation DARepoWalk
@dynamic heads, authors;

+ (instancetype)walkForRepo:(GTRepository *)repo {
	DARepoWalk *walk = self.new;
	walk.repo = repo;
	
	return walk;
}

- (GTSignature *)authorForCommit:(GTCommit *)commit {
	NSString *email = self.commitToAuthorMap[commit.SHA];
	return self.authorRefs[email];
}

- (id<DAGitOperation>)filter:(id<DAGitOperationFilter>)filter {
	DARepoWalk *filteredWalk = [DARepoWalk walkForRepo:self.repo];
	filteredWalk.commitToAuthorMap = self.commitToAuthorMap;
	filteredWalk.commitToBranchMap = self.commitToBranchMap;
	
	filteredWalk.allCommits = [filter filterCommits:self.allCommits];
	
	NSSet *allFilteredCommits = [NSSet setWithArray:filteredWalk.allCommits];
	
	NSMutableDictionary *filteredHeadRefs = self.headRefs.mutableCopy;
	NSMutableDictionary *filteredHeadCommits = self.headCommits.mutableCopy;
	{
		[self.class filterRefMap:&filteredHeadRefs enumeratedByKeys:self.heads containingCommitsMap:&filteredHeadCommits againstAllCommits:allFilteredCommits];
	}
	filteredWalk.headRefs = filteredHeadRefs.copy;
	filteredWalk.headCommits = filteredHeadCommits.copy;
	
	NSMutableDictionary *filteredAuthorRefs = self.authorRefs.mutableCopy;
	NSMutableDictionary *filteredAuthorCommits = self.authorCommits.mutableCopy;
	{
		[self.class filterRefMap:&filteredAuthorRefs enumeratedByKeys:self.authors containingCommitsMap:&filteredAuthorCommits againstAllCommits:allFilteredCommits];
	}
	filteredWalk.authorRefs = filteredAuthorRefs.copy;
	filteredWalk.authorCommits = filteredAuthorCommits.copy;
	
	return filteredWalk;
}

+ (void)filterRefMap:(NSMutableDictionary **)refs enumeratedByKeys:(NSArray *)keys containingCommitsMap:(NSMutableDictionary **)commits againstAllCommits:(NSSet *)allFilteredCommits {
	
	NSMutableDictionary *filteredRefs = *refs;
	NSMutableDictionary *filteredCommits = *commits;
	{
		for (NSString *key in keys) {
			NSArray *list = filteredCommits[key];
			
			int trailingIdx = 0;
			for (; trailingIdx < list.count; trailingIdx++) {
				if (![allFilteredCommits containsObject:list[trailingIdx]]) {
					break;
				}
			}
			
			if (0 == trailingIdx) {
				[filteredRefs removeObjectForKey:key];
				[filteredCommits removeObjectForKey:key];
			} else {
				filteredCommits[key] = [list subarrayWithRange:NSMakeRange(0, trailingIdx)];
			}
		}
	}
}

- (void)perform {
	NSError *err = nil;
	
	GTEnumerator *iter = [GTEnumerator.alloc initWithRepository:self.repo error:&err];
	
	if (![iter pushGlob:@"refs/remotes/origin/*" error:&err]) {
		[LLog error:@"Failed to pushGlob to enumarate commits."];
		return;
	}
	
	[iter resetWithOptions:GTEnumeratorOptionsTimeSort];
	
	NSArray *commits = nil;
	
	[NSObject startMeasurement];
	{
		commits = [iter allObjectsWithError:&err];
	}
	double period = [NSObject endMeasurement];
	[LLog info:@"%d Commits in Repository loaded in %.2f.", commits.count, period];
	
	NSArray *branches = [self.repo remoteBranchesWithError:nil];
	
	/*
	// verbose.
	{
		[LLog info:@"\n\n"];
		[LLog info:@"All Commits in repo (%d): ", commits.count];
		for (GTCommit *ci in commits) {
			[LLog info:@"0x%X %@ : %@ : %@", ci, ci.shortSHA, ci.SHA, ci.messageSummary];
		}
		[LLog info:@"-----"];
		
		for (GTBranch *br in branches) {
			[self performVerboseWalkOnBranch:br iter:iter];
		}
	}*/
	
	[NSObject startMeasurement];
	@autoreleasepool {
		[self traverseCommits:commits againstBranches:branches];
	}
	period = [NSObject endMeasurement];
	
	[LLog info:@"\n\n"];
	[LLog info:@"Stats for repo generated in %.2f (%d commits).", period, commits.count];
	[LLog info:@"\n"];
}
/*
- (void)performVerboseWalkOnBranch:(GTBranch *)branch iter:(GTEnumerator *)iter {
	NSError *err = nil;
	[iter pushSHA:branch.SHA error:&err];
	
	NSArray *commits = [iter allObjectsWithError:&err];
	
	[LLog info:@"\n\n"];
	[LLog info:@"%@ br_commits (%d): ", branch.name, commits.count];
	for (GTCommit *ci in commits) {
		[LLog info:@"0x%X %@ : %@ : %@", ci, ci.shortSHA, ci.SHA, ci.messageSummary];
	}
	[LLog info:@"-----"];
}*/

- (void)traverseCommits:(NSArray *)commits againstBranches:(NSArray *)branches {
	self.allCommits = commits.copy;
	
	NSMutableDictionary *commitBranchMap = @{}.mutableCopy;
	NSMutableDictionary *commitToAuthorMap = @{}.mutableCopy;
	
	NSMutableDictionary *headRefs = @{}.mutableCopy;
	NSMutableDictionary *headCommits = @{}.mutableCopy;
	
	NSMutableDictionary *authorRefs = @{}.mutableCopy;
	NSMutableDictionary *authorCommits = @{}.mutableCopy;
	
	NSMutableSet *heads = NSMutableSet.new;
	for (GTBranch *br in branches) {
		[heads addObject:br.OID.SHA];
		
		headRefs[br.OID.SHA] = br;
	}
	
	_headRefs = headRefs.copy;
	
	NSString *currentHead = nil;
	NSMutableArray *currentHeadCommits = nil;
	
	for (GTCommit *ci in commits) {
//		[LLog info:@"ci: %@", ci];
		
		if ([heads containsObject:ci.SHA]) {
			if (currentHead && currentHeadCommits) {
				headCommits[currentHead] = currentHeadCommits;
			}
			
			currentHead = ci.SHA;
			currentHeadCommits = @[].mutableCopy;
		}
		
		[currentHeadCommits addObject:ci];
		commitBranchMap[ci.SHA] = currentHead;
		
		@autoreleasepool {
			GTSignature *author = ci.author;
			authorRefs[author.email] = author;
			
			commitToAuthorMap[ci.SHA] = author.email;
			
			NSMutableArray *commitsByAuthor = authorCommits[author.email];
			if (!commitsByAuthor) {
				commitsByAuthor = @[].mutableCopy;
				authorCommits[author.email] = commitsByAuthor;
			}
			[commitsByAuthor addObject:ci];
		}
	}
	if (currentHead && currentHeadCommits) {
		headCommits[currentHead] = currentHeadCommits;
	}
	
	_authorRefs = authorRefs.copy;
	_authorCommits = authorCommits.copy;
	
	_commitToAuthorMap = commitToAuthorMap.copy;
	
	BOOL success = NO;
	NSError *err = nil;
	
	GTBranch *masterBranch = [self.repo currentBranchWithError:&err];
	masterBranch = [masterBranch trackingBranchWithError:&err success:&success];
	if (!success || !masterBranch) {
		[LLog error:@"Failed to retrieve upstream branch for local head branch. %s", __PRETTY_FUNCTION__];
		return;
	}
	
	NSString *masterHead = masterBranch.OID.SHA;
	
	if (![masterHead isEqualToString:currentHead]) {
		size_t ahead = 0, behind = 0;
		
		GTBranch *latestBranch = headRefs[currentHead];
		
		success = [masterBranch calculateAhead:&ahead behind:&behind relativeTo:latestBranch error:&err];
		if (!success) {
			[LLog error:@"Failed to calculateAhead:Behind: between %@ and %@. %s", masterBranch.shortName, latestBranch.shortName, __PRETTY_FUNCTION__];
		} else {
			[LLog info:@"%@ branch is ahead by %d commits against %@ branch which is %d commits behind.", masterBranch.shortName, ahead, latestBranch.shortName, behind];
			
			NSUInteger tailSize = [headCommits[currentHead] count] - behind;
			
			NSArray *heading = [headCommits[currentHead] subarrayWithRange:NSMakeRange(0, behind)];
			NSArray *trailing = [headCommits[currentHead] subarrayWithRange:NSMakeRange(behind, tailSize)];
			
			headCommits[currentHead] = heading;
			headCommits[masterHead] = [headCommits[masterHead] arrayByAddingObjectsFromArray:trailing];
			
			for (GTCommit *ci in trailing) {
				commitBranchMap[ci.SHA] = masterHead;
			}
		}
	} else {
		// master branch is already in right place
	}
	
	_headCommits = headCommits.copy;
	_commitToBranchMap = commitBranchMap.copy;
}

/*
- (void)filterCommits:(NSArray *)commits byFirstDaysCount:(int)days {
	for (GTCommit *ci in commits) {
		
	}
}*/

#pragma mark Properties

- (NSArray *)heads {
	return self.headRefs.allKeys;
}

- (NSArray *)authors {
	return self.authorRefs.allKeys;
}

@end
