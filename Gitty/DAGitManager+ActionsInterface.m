//
//  DAGitManager+ActionsInterface.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitManager+ActionsInterface.h"

@implementation DAGitManager (ActionsInterface)

- (NSString *)localPathForRepoWithName:(NSString *)name atServer:(DAGitServer *)server {
	return [[self.repoRootPath concatPath:server.saveDirectoryName] concatPath:name];
}

- (NSString *)remotePathForRepoWithName:(NSString *)name atServer:(DAGitServer *)server {
	return [NSString stringWithFormat:@"%@%@/%@", server.transferProtocol, server.gitBaseUrl, name];
}

@end
