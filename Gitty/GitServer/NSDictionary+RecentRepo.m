//
//  NSDictionary+RecentRepo.m
//  Gitty
//
//  Created by kernel on 25/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "NSDictionary+RecentRepo.h"
#import "DAGitServer+Creation.h"

@implementation NSDictionary (RecentRepo)
@dynamic relativePath, lastAccessDate;

- (NSComparisonResult)compare:(NSDictionary *)anotherRepo {
	return [self.lastAccessDate compare:anotherRepo.lastAccessDate];
}

#pragma mark Properties

- (NSString *)relativePath {
	return self[RecentRepoRelativePath];
}

- (NSDate *)lastAccessDate {
	return self[RecentRepoLastAccessDate];
}

@end
