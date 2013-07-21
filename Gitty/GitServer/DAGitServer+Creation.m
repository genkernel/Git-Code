//
//  DAGitServer+Creation.m
//  Gitty
//
//  Created by kernel on 16/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitServer+Creation.h"

NSString *ServerName = @"Name";
NSString *ServerGitBaseUrl = @"GitBaseUrl";
NSString *SaveDirectory = @"SaveDirectoryName";
NSString *LogoIcon = @"LogoIcon";
NSString *TransferProtocol = @"TransferProtocol";
NSString *SupportedProtocols = @"SupportedProtocols";
NSString *RecentRepoPath = @"RecentRepoPath";
NSString *RecentRepos = @"RecentRepos";
NSString *RecentBranchName = @"RecentBranchName";

@implementation DAGitServer (Creation)
@dynamic docsPath, settingsPath;

- (void)createSettingsFolderIfNeeded {
	[UIApplication.sharedApplication.fs createDirectoryIfNotExists:self.settingsPath];
}

- (NSString *)docsPath {
	return UIApplication.sharedApplication.documentsPath;
}

- (NSString *)settingsPath {
	return [self.docsPath stringByAppendingPathComponent:self.name];
}

- (void)loadRecentReposFromDict:(NSDictionary *)repos {
	_recentReposDict = [NSMutableDictionary dictionaryWithCapacity:repos.count + 10];
	
	for (NSDictionary *info in repos.allValues) {
		DAGitRepo *repo = [DAGitRepo storageWithInitialProperties:info];
		_recentReposDict[repo.relativePath] = repo;
	}
}

@end
