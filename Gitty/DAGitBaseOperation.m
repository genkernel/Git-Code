//
//  DAGitBaseOperation.m
//  Git Code
//
//  Created by Altukhov Anton on 9/4/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DAGitBaseOperation.h"

@implementation DAGitBaseOperation
@synthesize filter;
@synthesize hasMoreCommitsToProcess = _hasMoreCommitsToProcess;

- (void)perform {
	[Logger info:@"Dummy. %s", __PRETTY_FUNCTION__];
}

- (id<DAGitOperation>)filter:(id<DAGitOperationFilter>)filter {
	[Logger info:@"Dummy. %s", __PRETTY_FUNCTION__];
	
	return nil;
}

@end
