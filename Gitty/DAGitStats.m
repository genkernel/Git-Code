//
//  DAGitStats.m
//  Gitty
//
//  Created by kernel on 17/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitStats.h"

#import "DAGitManager+Internal.h"

@interface DAGitStats ()
@property (strong, nonatomic, readonly) GTRepository *repo;
@end

@implementation DAGitStats

+ (instancetype)statsForRepository:(GTRepository *)repo {
	DAGitStats *stats = self.new;
	[stats load:repo];
	
	return stats;
}

- (void)load:(GTRepository *)repo {
	_repo = repo;
}

- (void)performSyncOperation:(id<DAGitOperation>)operation {
	dispatch_sync(DAGitManager.manager.q, ^{
		[operation perform];
	});
}

- (void)performAsyncOperation:(id<DAGitOperation>)operation completionHandler:(void(^)())handler {
	NSOperationQueue *callee = NSOperationQueue.currentQueue;
	
	dispatch_async(DAGitManager.manager.q, ^{
		[operation perform];
		
		if (handler) {
			[callee addOperationWithBlock:^{
				handler();
			}];
		}
	});
}

@end
