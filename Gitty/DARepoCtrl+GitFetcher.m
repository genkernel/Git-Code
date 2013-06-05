//
//  DARepoCtrl+GitFetcher.m
//  Gitty
//
//  Created by kernel on 4/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl+GitFetcher.h"

@implementation DARepoCtrl (GitFetcher)

- (NSArray *)loadCommitsInBranch:(GTBranch *)branch betweenNowAndDate:(NSDate *)date {
	NSError *err = nil;
	NSMutableArray *commits = [NSMutableArray arrayWithCapacity:2000];
	
	GTEnumeratorOptions opts = GTEnumeratorOptionsTimeSort;
	[self.currentRepo enumerateCommitsBeginningAtSha:branch.sha sortOptions:opts error:&err usingBlock:^(GTCommit *commit, BOOL *stop) {
		[commits addObject:commit];
	}];
	
	return commits;
}

@end
