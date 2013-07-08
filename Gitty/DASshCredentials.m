//
//  DASshCredentials.m
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASshCredentials.h"

static NSString *PrivateKeyFileName = @"id_rsa";
static NSString *PublicKeyFileName = @"id_rsa.pub";

@interface DASshCredentials ()
@property (strong, nonatomic, readonly) NSString *docsPath;
@end

@implementation DASshCredentials
@dynamic docsPath;
@dynamic publicKeyPath, privateKeyPath, passphrase;

+ (instancetype)manager {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	return instance;
}

- (NSString *)docsPath {
	return UIApplication.sharedApplication.documentsPath;
}

- (NSString *)publicKeyPath {
	return [self.docsPath stringByAppendingPathComponent:PublicKeyFileName];
}

- (NSString *)privateKeyPath {
	return [self.docsPath stringByAppendingPathComponent:PrivateKeyFileName];
}

- (NSString *)passphrase {
	// TODO: impl passphrase.
	return @"superuser!";
}

@end
