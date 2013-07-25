//
//  DAGitServer.h
//  Gitty
//
//  Created by kernel on 30/11/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "NSDictionary+RecentRepo.h"

extern NSString *SshTransferProtocol;

@interface DAGitServer : NSObject {
	NSMutableDictionary *_recentReposDict;
}
+ (instancetype)serverWithDictionary:(NSDictionary *)dict;

- (void)addOrUpdateRecentRepoWithRelativePath:(NSString *)path;
- (void)removeRecentRepoByRelativePath:(NSString *)path;

@property (strong, nonatomic, readonly) NSDictionary *saveDict;

@property (strong, nonatomic, readonly) NSString *gitBaseUrl;
@property (strong, nonatomic) NSString *recentRepoPath, *recentBranchName;
@property (strong, nonatomic, readonly) NSArray *reposByAccessTime;

@property (strong, nonatomic) NSString *transferProtocol;
@property (strong, nonatomic, readonly) NSArray *supportedProtocols;

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *logoIconName;
@property (strong, nonatomic, readonly) NSString *saveDirectoryName;
@end
