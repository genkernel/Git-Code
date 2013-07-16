//
//  DASshKeyInfo.m
//  Gitty
//
//  Created by kernel on 14/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASshKeyInfo.h"
#import "STKeychain.h"

static NSString *PrivateKeyFileName = @"id_rsa";
static NSString *PublicKeyFileName = @"id_rsa.pub";

@interface DASshKeyInfo ()
@property (strong, nonatomic, readonly) NSString *rootPath;
@property (strong, nonatomic) DAGitServer *server;
@end

@implementation DASshKeyInfo
@dynamic rootPath, publicKeyPath, privateKeyPath;

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
	[info loadPassphraseFromKeychain];
	
	return info;
}

- (void)loadPassphraseFromKeychain {
	NSError *err = nil;
	_passphrase = [STKeychain getPasswordForUsername:self.server.name andServiceName:SshTransferProtocol error:&err];
	
	if (err) {
		[Logger error:@"Failed to load existing passphrase from secure keychain for server: %@", self.server.name];
	}
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

- (void)saveNewPassphrase:(NSString *)passphrase {
	NSError *err = nil;
	BOOL saved = [STKeychain storeUsername:self.server.name andPassword:passphrase forServiceName:SshTransferProtocol updateExisting:YES error:&err];
	
	if (!saved || err) {
		[Logger error:@"Failed to save new passphrase securely for server: %@", self.server.name];
	}
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (1 == buttonIndex) {
		UITextField *textField = [alertView textFieldAtIndex:0];
		[self saveNewPassphrase:textField.text];
	} else {
		[Logger info:@"SSH passphrase editing skiped with buttonIndex: %d", buttonIndex];
	}
}

@end
