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
@end

@implementation DARepoWalk
@dynamic heads;

+ (instancetype)walkForRepo:(GTRepository *)repo {
	DARepoWalk *walk = self.new;
	walk.repo = repo;
	
	return walk;
}

- (void)dealloc {
	[Logger info:@"HI"];
}

- (void)perform {
	NSError *err = nil;
	
	GTEnumerator *iter = [GTEnumerator.alloc initWithRepository:self.repo error:&err];
	
	if (![iter pushGlob:@"refs/remotes/origin/*" error:&err]) {
		[Logger error:@"Failed to pushGlob to enumarate commits."];
		return;
	}
	
	[iter resetWithOptions:GTEnumeratorOptionsTimeSort];
	
	NSArray *commits = nil;
	
	[NSObject startMeasurement];
	{
		commits = [iter allObjectsWithError:&err];
	}
	double period = [NSObject endMeasurement];
	[Logger info:@"%d Commits in Repository loaded in %.2f.", commits.count, period];
	
	NSArray *branches = [self.repo remoteBranchesWithError:nil];
	
	/*
	// verbose.
	{
		[Logger info:@"\n\n"];
		[Logger info:@"All Commits in repo (%d): ", commits.count];
		for (GTCommit *ci in commits) {
			[Logger info:@"0x%X %@ : %@ : %@", ci, ci.shortSHA, ci.SHA, ci.messageSummary];
		}
		[Logger info:@"-----"];
		
		for (GTBranch *br in branches) {
			[self performVerboseWalkOnBranch:br iter:iter];
		}
	}*/
	
	[self traverseCommits:commits againstBranches:branches];
}
/*
- (void)performVerboseWalkOnBranch:(GTBranch *)branch iter:(GTEnumerator *)iter {
	NSError *err = nil;
	[iter pushSHA:branch.SHA error:&err];
	
	NSArray *commits = [iter allObjectsWithError:&err];
	
	[Logger info:@"\n\n"];
	[Logger info:@"%@ br_commits (%d): ", branch.name, commits.count];
	for (GTCommit *ci in commits) {
		[Logger info:@"0x%X %@ : %@ : %@", ci, ci.shortSHA, ci.SHA, ci.messageSummary];
	}
	[Logger info:@"-----"];
}*/

- (void)traverseCommits:(NSArray *)commits againstBranches:(NSArray *)branches {
	_statsCommitsByAuthor = NSMutableDictionary.new;
	_statsCommitsByBranch = NSMutableDictionary.new;
	
	NSMutableDictionary *headRefs = @{}.mutableCopy;
	NSMutableDictionary *headCommits = @{}.mutableCopy;
	
	NSMutableSet *heads = NSMutableSet.new;
	for (GTBranch *br in branches) {
		[heads addObject:br.SHA];
		
		headRefs[br.SHA] = br;
	}
	
	_headRefs = headRefs.copy;
	
	NSString *currentHead = nil;
	NSMutableArray *currentHeadCommits = nil;
	
	for (GTCommit *ci in commits) {
		[Logger info:@"ci: %@", ci.shortSHA];
		
		if ([heads containsObject:ci.SHA]) {
			if (currentHead && currentHeadCommits) {
				headCommits[currentHead] = currentHeadCommits;
			}
			
			currentHead = ci.SHA;
			currentHeadCommits = @[].mutableCopy;
		}
		
		[currentHeadCommits addObject:ci];
	}
	if (currentHead && currentHeadCommits) {
		headCommits[currentHead] = currentHeadCommits;
	}
	
	BOOL success = NO;
	NSError *err = nil;
	
	GTBranch *masterBranch = [self.repo currentBranchWithError:&err];
	masterBranch = [masterBranch trackingBranchWithError:&err success:&success];
	if (!success || !masterBranch) {
		[Logger error:@"Failed to retrieve upstream branch for local head branch. %s", __PRETTY_FUNCTION__];
		return;
	}
	
	NSString *masterHead = masterBranch.SHA;
	
	if (![masterHead isEqualToString:currentHead]) {
		size_t ahead = 0, behind = 0;
		
		GTBranch *latestBranch = headRefs[currentHead];
		
		success = [masterBranch calculateAhead:&ahead behind:&behind relativeTo:latestBranch error:&err];
		if (!success) {
			[Logger error:@"Failed to calculateAhead:Behind: between %@ and %@. %s", masterBranch.shortName, latestBranch.shortName, __PRETTY_FUNCTION__];
		} else {
			[Logger info:@"%@ branch is ahead by %d commits against %@ branch which is %d commits behind.", masterBranch.shortName, ahead, latestBranch.shortName, behind];
			
			NSUInteger tailSize = [headCommits[currentHead] count] - behind;
			
			NSArray *heading = [headCommits[currentHead] subarrayWithRange:NSMakeRange(0, behind)];
			NSArray *trailing = [headCommits[currentHead] subarrayWithRange:NSMakeRange(behind, tailSize)];
			
			headCommits[currentHead] = heading;
			headCommits[masterHead] = [headCommits[masterHead] arrayByAddingObjectsFromArray:trailing];
		}
	} else {
		// master branch is already in right place
	}
	
	_headCommits = headCommits.copy;
	
	[Logger info:@"\n\n"];
	[Logger info:@"Heads: %@", self.headCommits];
	[Logger info:@"-----"];
}

#pragma mark Properties

- (NSArray *)heads {
	return self.headRefs.allValues;
}

@end
