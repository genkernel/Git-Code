//
//  DAGitLatestCommitStats.m
//  Git Code
//
//  Created by Altukhov Anton on 9/4/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DAGitLatestCommitStats.h"

@interface DAGitLatestCommitStats ()
@end

@implementation DAGitLatestCommitStats

+ (instancetype)filterShowingLatestCommitsOfCount:(NSUInteger)count {
	DAGitLatestCommitStats *stats = DAGitLatestCommitStats.new;
	stats.latestCommitsCount = count;
	
	return stats;
}

- (BOOL)filterNextCommit:(GTCommit *)ci {
	if (self.processedCommitsCount < self.latestCommitsCount) {
		_processedCommitsCount++;
		
		return YES;
	} else {
		return NO;
	}
}

@end
