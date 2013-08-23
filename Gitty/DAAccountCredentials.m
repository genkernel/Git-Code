//
//  DAAccountCredentials.m
//  Gitty
//
//  Created by kernel on 23/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAAccountCredentials.h"
#import "STKeychain.h"

NSString *UsernameKey = @"username", *PasswordKey = @"password";

@implementation DAAccountCredentials

+ (instancetype)manager {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	return instance;
}

- (BOOL)saveUsername:(NSString *)name password:(NSString *)password onServer:(DAGitServer *)server {
	return [STKeychain storeUsername:name andPassword:password forServiceName:server.name updateExisting:YES error:nil];
}

- (NSString *)getPasswordForUsername:(NSString *)name atServer:(DAGitServer *)server {
	return [STKeychain getPasswordForUsername:name andServiceName:server.name error:nil];
}

- (BOOL)deleteUsername:(NSString *)name fromServer:(DAGitServer *)server {
	return [STKeychain deleteItemForUsername:name andServiceName:server.name error:nil];
}

@end
