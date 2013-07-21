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
@dynamic reposByAccessTime;
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
		_recentBranchName = dict[RecentBranchName];
		
		[self createSettingsFolderIfNeeded];
		[self loadRecentReposFromDict:dict[RecentRepos]];
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
			 RecentRepos: self.recentReposDict.copy,
			 RecentBranchName: self.recentBranchName};
}

- (NSArray *)reposByAccessTime {
	NSArray *items = [self.recentReposDict.allValues sortedArrayUsingSelector:@selector(compare:)];
	return items.reverseObjectEnumerator.allObjects;
}

@end
