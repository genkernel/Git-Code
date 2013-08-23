//
//  DAAccountCredentials.h
//  Gitty
//
//  Created by kernel on 23/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *UsernameKey, *PasswordKey;

@interface DAAccountCredentials : NSObject
+ (instancetype)manager;

- (BOOL)saveUsername:(NSString *)name password:(NSString *)password onServer:(DAGitServer *)server;
- (NSString *)getPasswordForUsername:(NSString *)name atServer:(DAGitServer *)server;
- (BOOL)deleteUsername:(NSString *)name fromServer:(DAGitServer *)server;
@end
