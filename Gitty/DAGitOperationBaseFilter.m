//
//  DAGitBaseFilter.m
//  Git Code
//
//  Created by Altukhov Anton on 9/4/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DAGitOperationBaseFilter.h"

@implementation DAGitOperationBaseFilter
@synthesize processedCommitsCount = _processedCommitsCount;

- (BOOL)filterNextCommit:(GTCommit *)ci {
	[LLog info:@"Dummy. %s", __PRETTY_FUNCTION__];
	
	return NO;
}

- (NSArray *)filterCommits:(NSArray *)list {
	[LLog info:@"Dummy. %s", __PRETTY_FUNCTION__];
	
	return nil;
}

@end
