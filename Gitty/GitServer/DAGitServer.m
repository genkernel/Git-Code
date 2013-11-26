//
//  DAGitServer.m
//  Gitty
//
//  Created by kernel on 30/11/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "DAGitServer.h"
#import "DAGitServer+Creation.h"

NSString *SshTransferProtocol = @"ssh://";

@interface DAGitServer ()
@property (strong, nonatomic, readonly) NSMutableDictionary *recentReposDict;
@end

@implementation DAGitServer
@dynamic saveDict;
@dynamic repos, reposByAccessTime, activeRepo;
// Synthesize for explicitly-defined ivar.
@synthesize recentReposDict = _recentReposDict;

+ (instancetype)serverWithDictionary:(NSDictionary *)dict {
	return [self.alloc initWithDictionary:dict];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	self = [self init];
	if (self) {
		_name = dict[ServerName];
		_gitBaseUrl = dict[ServerGitBaseUrl];
		_saveDirectoryName = dict[SaveDirectory];
		_logoIconName = dict[LogoIcon];
		_transferProtocol = dict[TransferProtocol];
		_supportedProtocols = dict[SupportedProtocols];
		_recentRepoPath = dict[RecentRepoPath];
		
		_recentReposDict = [NSMutableDictionary dictionaryWithDictionary:dict[RecentRepos]];
		
		[self createSettingsFolderIfNeeded];
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"[%@, 0x%X]", self.name, (int)self];
}

- (NSDictionary *)saveDict {
	return @{ServerName: self.name,
			 ServerGitBaseUrl: self.gitBaseUrl,
			 SaveDirectory: self.saveDirectoryName,
			 LogoIcon: self.logoIconName,
			 TransferProtocol: self.transferProtocol,
			 SupportedProtocols: self.supportedProtocols,
			 RecentRepoPath: self.recentRepoPath,
			 RecentRepos: self.recentReposDict.copy};
}

#pragma mark Recent repo

- (void)addOrUpdateRecentRepoWithRelativePath:(NSString *)path {
	NSDictionary *repo = self.recentReposDict[path];
	
	if (repo) {
		[self addOrUpdateRecentRepoWithRelativePath:path activeBranchName:repo.activeBranchName];
	} else {
		[self addNewRecentRepoWithRelativePath:path];
	}
}

- (void)addOrUpdateRecentRepoWithRelativePath:(NSString *)path activeBranchName:(NSString *)branchName {
	if (!branchName) {
		// Support old config format.
		branchName = @"master";
	}
	
	self.recentReposDict[path] = [self createRecentRepoWithRelativePath:path branchName:branchName];
}

- (void)addNewRecentRepoWithRelativePath:(NSString *)path {
	self.recentReposDict[path] = [self createRecentRepoWithRelativePath:path branchName:@"master"];
}

- (void)removeRecentRepoByRelativePath:(NSString *)path {
	[self.recentReposDict removeObjectForKey:path];
}

#pragma mark Properties

- (NSDictionary *)activeRepo {
	return self.recentReposDict[self.recentRepoPath];
}

- (NSDictionary *)repos {
	return self.recentReposDict;
}

- (NSArray *)reposByAccessTime {
	NSArray *items = [self.recentReposDict.allValues sortedArrayUsingSelector:@selector(compare:)];
	return items.reverseObjectEnumerator.allObjects;
}

@end
