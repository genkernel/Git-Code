//
//  DAGitManager.m
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitManager.h"
#import "DAGitManager+Internal.h"
#import "DAGitManager+ActionsInterface.h"

#import "DAGitAction+ManagerAccess.h"

static id sharedInstance = nil;
static NSString *RepoRootFolderName = @"Repos";
static NSString *DeletableFolderSuffix = @"md";

@interface DAGitManager ()
@property (nonatomic, nonatomic, readwrite) dispatch_queue_t q;
@end

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
		[self.app.fs createDirectoryIfNotExistsAtPath:self.repoRootPath];
		
		// libgit module is not multithreaded.
		_q = dispatch_queue_create("gitcode.qit.operations", DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

- (void)request:(DAGitAction *)action {
	[self request:action delegateQueue:dispatch_get_main_queue()];
}

- (void)request:(DAGitAction *)action delegateQueue:(dispatch_queue_t)queue {
	action.manager = self;
	action.delegateQueue = queue;
	
	dispatch_async(self.q, ^{
		[action exec];
		[action finilize];
	});
}

- (void)requestRecursiveDeleteBackgroundOperationPath:(NSString *)path {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[self.app.fs deleteDirectoryAndItsContentsAtPath:path];
		
		[LLog info:@"Repo deleted: %@", path];
	});
}

#pragma mark Public

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

- (void)removeExistingRepo:(NSString *)repoName forServer:(DAGitServer *)server {
	NSString *path = [self localPathForRepoWithName:repoName atServer:server];

	if ([self.app.fs isDirectoryExistentAtPath:path]) {
		NSString *deletePath = [path stringByAppendingPathExtension:DeletableFolderSuffix];
		[self.app.fs moveItemAtPath:path toPath:deletePath error:nil];

		[self requestRecursiveDeleteBackgroundOperationPath:deletePath];
	}
}

- (void)scanAllDeletableLocalReposAndDelete {
	NSArray *servers = [self.app.fs contentsOfDirectoryAtPath:self.repoRootPath error:nil];
	for (NSString *serverName in servers) {
		NSString *serverPath = [self.repoRootPath stringByAppendingPathComponent:serverName];
		
		if (![self.app.fs isDirectoryExistentAtPath:serverPath]) {
			continue;
		}
		
		NSArray *users = [self.app.fs contentsOfDirectoryAtPath:serverPath error:nil];
		for (NSString *userName in users) {
			NSString *userPath = [serverPath stringByAppendingPathComponent:userName];
			if (![self.app.fs isDirectoryExistentAtPath:userPath]) {
				continue;
			}
			
			NSArray *repos = [self.app.fs contentsOfDirectoryAtPath:userPath error:nil];
			for (NSString *repoName in repos) {
				NSString *repoPath = [userPath stringByAppendingPathComponent:repoName];
				
				if (![self.app.fs isDirectoryExistentAtPath:repoPath]) {
					continue;
				}
				if (![repoPath.pathExtension isEqualToString:DeletableFolderSuffix]) {
					continue;
				}
				
				[self requestRecursiveDeleteBackgroundOperationPath:repoPath];
			}
		}
	}
}

#pragma mark Properties

- (UIApplication *)app {
	return UIApplication.sharedApplication;
}

@end
