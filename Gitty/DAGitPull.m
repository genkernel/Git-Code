//
//  DAGitPull.m
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitPull.h"

@interface DAGitPull ()
@property (strong, nonatomic) GTRepository *repo;
@end

@implementation DAGitPull

+ (instancetype)pullForRepository:(GTRepository *)repo {
	DAGitPull *pull = self.new;
	pull.repo = repo;
	
	return pull;
}

- (void)exec {
	int code = [self.repo pull];
	if (GIT_EEXISTS == code) {
		// Silence.
	} else if (GIT_OK != code) {
		NSDictionary *info = @{NSLocalizedDescriptionKey: @"Failed to Pull for repo."};
		_completionError = [NSError errorWithDomain:@"libgit2" code:code userInfo:info];
	}
}

@end
