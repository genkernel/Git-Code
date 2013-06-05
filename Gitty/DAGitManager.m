//
//  DAGitManager.m
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitManager.h"
#import "DAGitManager+ActionsInterface.h"
#import "DAGitAction+ManagerAccess.h"

static id sharedInstance = nil;
static NSString *RepoRootFolderName = @"Repos";

@implementation DAGitManager
@dynamic app;

+ (instancetype)manager {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = self.new;
	});
	return sharedInstance;
}

+ (id)alloc {
	if (sharedInstance) {
		return sharedInstance;
	}
	return super.alloc;
}

- (id)init {
	self = [super init];
	if (self) {
		_repoRootPath = [self.app.cachesPath stringByAppendingPathComponent:RepoRootFolderName];
		[self.app.fs createDirectoryIfNotExists:self.repoRootPath];
	}
	return self;
}

- (void)request:(DAGitAction *)action {
	[self request:action delegateQueue:dispatch_get_main_queue()];
}

- (void)request:(DAGitAction *)action delegateQueue:(dispatch_queue_t)queue {
	action.manager = self;
	action.delegateQueue = queue;
	
	dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(q, ^{
		[action exec];
		[action finilize];
	});
}

#pragma mark Magics

- (BOOL)isLocalRepoExistent:(NSString *)repoFullName forServer:(DAGitServer *)server {
	NSString *path = [self localPathForRepoWithName:repoFullName atServer:server];
	
	BOOL isDirectory = NO;
	BOOL exists = [self.app.fs fileExistsAtPath:path isDirectory:&isDirectory];
	
	return exists && isDirectory;
}

- (GTRepository *)localRepoWithName:(NSString *)repoFullName forServer:(DAGitServer *)server {
	NSString *path = [self localPathForRepoWithName:repoFullName atServer:server];
	NSURL *url = [NSURL fileURLWithPath:path isDirectory:YES];
	
	return [GTRepository repositoryWithURL:url error:nil];
}

#pragma mark Properties

- (UIApplication *)app {
	return UIApplication.sharedApplication;
}

@end
