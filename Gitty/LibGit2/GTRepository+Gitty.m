//
//  GTRepository+Gitty.m
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "GTRepository+Gitty.h"

@implementation GTRepository (Gitty)

- (int)pull {
	git_clone_options opts = self.cloneOptions;
	GTRemote *remote = self.configuration.remotes.lastObject;
	
	git_remote_check_cert(remote.git_remote, 0);
	
	return fetch_from_remote(self.git_repository, remote.git_remote, &opts);
}
/*
- (void)demoMergeFromFetchHead {
	//	GIT_MERGE_AUTOMERGE_NORMAL
	
	GTBranch *branch = nil;
	GTRepository *repo = nil;
	
	git_reference *resolved;
	int error = git_reference_resolve(&resolved, branch.reference.git_reference);
	if (0 != error) {
		[Logger error:@"err"];
		//		return error;
	}
	
	git_merge_head *head;
	error = git_merge_head_from_fetchhead(&head, repo.git_repository, branch.name.UTF8String, self.URLString.UTF8String, git_reference_target(resolved));
	if (error != 0) {
		[Logger error:@"err 2"];
	}
	
	git_reference_free(resolved);
}*/

@end
