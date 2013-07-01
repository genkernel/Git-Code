//
//  DAServerManager.h
//  Gitty
//
//  Created by kernel on 30/11/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "DAGitServer.h"

@interface DAServerManager : NSObject
+ (instancetype)manager;

- (void)addNewServer:(DAGitServer *)server;
- (void)save;

@property (strong, nonatomic, readonly) NSDictionary *namedList;
@property (strong, nonatomic, readonly) NSArray *list;
@end
