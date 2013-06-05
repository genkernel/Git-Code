//
//  DAGitManager+ActionsInterface.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitManager.h"

@interface DAGitManager (ActionsInterface)
- (NSString *)localPathForRepoWithName:(NSString *)name atServer:(DAGitServer *)server;
- (NSString *)remotePathForRepoWithName:(NSString *)name atServer:(DAGitServer *)server;
@end
