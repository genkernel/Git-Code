//
//  DASshKeyInfo.m
//  Gitty
//
//  Created by kernel on 14/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASshKeyInfo.h"

static NSString *PrivateKeyFileName = @"id_rsa";
static NSString *PublicKeyFileName = @"id_rsa.pub";

@interface DASshKeyInfo ()
@property (strong, nonatomic, readonly) NSString *rootPath;
@property (strong, nonatomic) DAGitServer *server;
@end

@implementation DASshKeyInfo
@dynamic rootPath;
@dynamic publicKeyPath, privateKeyPath, passphrase;

+ (instancetype)globalKeysInfo {
	static id info = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		info = self.new;
	});
	return info;
}

+ (instancetype)keysInfoForServer:(DAGitServer *)server {
	DASshKeyInfo *info = self.new;
	info.server = server;
	
	return info;
}

#pragma mark Properties

- (NSString *)rootPath {
	NSString *docsPath = UIApplication.sharedApplication.documentsPath;
	
	if (self.server) {
		return [docsPath stringByAppendingPathComponent:self.server.name];
	} else {
		return docsPath;
	}
}

- (NSString *)publicKeyPath {
	return [self.rootPath stringByAppendingPathComponent:PublicKeyFileName];
}

- (NSString *)privateKeyPath {
	return [self.rootPath stringByAppendingPathComponent:PrivateKeyFileName];
}

- (NSString *)passphrase {
	// TODO: impl passphrase.
	return @"superuser!";
}

@end
