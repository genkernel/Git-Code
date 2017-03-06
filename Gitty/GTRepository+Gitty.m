//
//  GTRepository+Gitty.m
//  Gitty
//
//  Created by Shawn Altukhov on 23/03/2014.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "GTRepository+Gitty.h"
//#ifdef DEBUG
//#import <ObjectiveGit/GTCredential+Private.h>
//#else
//#import "GTCredential+Private.h"
//#endif

@import ObjectiveGit;

@implementation GTRepository (Gitty)

- (BOOL)pullFromRemote:(GTRemote *)_remote credentials:(GTCredentialProvider *)credentialProvider {
	NSMutableDictionary *opts = @{}.mutableCopy;
	opts[GTRepositoryRemoteOptionsFetchPrune] = @(GTFetchPruneOptionYes);
	opts[GTRepositoryRemoteOptionsDownloadTags] = @(GTRemoteDownloadTagsAll);
	
	if (credentialProvider != nil) {
		opts[GTRepositoryRemoteOptionsCredentialProvider] = credentialProvider;
	}
	
	return [self fetchRemote:_remote withOptions:opts error:NULL progress:^(const git_transfer_progress * _Nonnull progress, BOOL * _Nonnull stop) {
		NSLog(@"%s %d %d %d", __PRETTY_FUNCTION__, progress->total_objects, progress->received_objects, progress->local_objects);
	}];
}

@end
