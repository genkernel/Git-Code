//
//  DAGitRepo.m
//  Gitty
//
//  Created by kernel on 21/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitRepo.h"

@implementation DAGitRepo
@dynamic relativePath, lastAccessDate;

- (NSComparisonResult)compare:(DAGitRepo *)anotherRepo {
	return [self.lastAccessDate compare:anotherRepo.lastAccessDate];
}

@end
