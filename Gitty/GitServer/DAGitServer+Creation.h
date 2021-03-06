//
//  DAGitServer+Creation.h
//  Gitty
//
//  Created by kernel on 16/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitServer.h"

extern NSString *ServerName;
extern NSString *ServerGitBaseUrl;
extern NSString *SaveDirectory;
extern NSString *LogoIcon;
extern NSString *TransferProtocol;
extern NSString *SupportedProtocols;
extern NSString *RecentRepoPath;
extern NSString *RecentRepos;

// Recent repo.
extern NSString *RecentRepoRelativePath;
extern NSString *RecentRepoLastAccessDate;
extern NSString *ActiveBranchName;

@interface DAGitServer (Creation)
- (void)createSettingsFolderIfNeeded;
- (NSDictionary *)createRecentRepoWithRelativePath:(NSString *)path branchName:(NSString *)branchName;

// Private.
@property (strong, nonatomic, readonly) NSString *docsPath, *settingsPath;
@end
