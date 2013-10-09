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

// Recent repo.
NSString *RecentRepoRelativePath = @"relativePath";
NSString *RecentRepoLastAccessDate = @"lastAccessDate";
NSString *ActiveBranchName = @"activeBranchName";

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

- (NSDictionary *)createRecentRepoWithRelativePath:(NSString *)path branchName:(NSString *)branchName {
	return @{RecentRepoRelativePath: path, RecentRepoLastAccessDate: NSDate.date, ActiveBranchName: branchName};
}

@end
