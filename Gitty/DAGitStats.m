//
//  DAGitStats.m
//  Gitty
//
//  Created by kernel on 17/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitStats.h"

@interface DAGitStats ()
@property (strong, nonatomic) GTRepository *repo;
@end

@implementation DAGitStats

+ (instancetype)statsForRepository:(GTRepository *)repo {
	DAGitStats *stats = self.new;
	stats.repo = repo;
	
	return stats;
}

@end
