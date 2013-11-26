//
//  DASshCredentials.h
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASshKeyInfo.h"

@interface DASshCredentials : NSObject
+ (instancetype)manager;

- (void)scanNewKeyArchives;

- (BOOL)hasSshKeypairSupportForServer:(DAGitServer *)server;
- (DASshKeyInfo *)keysForServer:(DAGitServer *)server;
@end
