//
//  DASshKeyInfo.m
//  Gitty
//
//  Created by kernel on 14/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASshKeyInfo.h"
#import "STKeychain.h"

NSString *DASSHKeysStateChanged = @"DASSHKeysStateChanged";

static NSString *PrivateKeyFileName = @"id_rsa";
static NSString *PublicKeyFileName = @"id_rsa.pub";

@interface DASshKeyInfo ()
@property (strong, nonatomic) DAGitServer *server;
@property (strong, nonatomic, readonly) NSString *rootPath;

@property (strong, nonatomic, readonly) DASshKeyInfoConfig *cfg;
@property (strong, nonatomic, readonly) NSString *cfgFilePath;
@end

@implementation DASshKeyInfo
@dynamic rootPath, publicKeyPath, privateKeyPath;

+ (instancetype)keysInfoForServer:(DAGitServer *)server {
	DASshKeyInfo *info = self.new;
	
	info.server = server;
	
	[info loadConfig];
	[info loadPassphraseFromKeychain];
	
	return info;
}

- (void)loadConfig {
	
	NSString *path = [UIApplication.sharedApplication.documentsPath stringByAppendingPathComponent:self.server.name];
	_cfgFilePath = [path stringByAppendingPathComponent:@".SshInfo.plist"];
	
	if ([UIApplication.sharedApplication.fs isFileExistent:self.cfgFilePath]) {
		NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:self.cfgFilePath];
		
		_cfg = [DASshKeyInfoConfig storageWithInitialProperties:info];
	} else {
		_cfg = DASshKeyInfoConfig.new;
	}
	
	_username = self.cfg.username;
}

- (void)loadPassphraseFromKeychain {
	if (!self.username) {
		return;
	}
	
	NSError *err = nil;
	_passphrase = [STKeychain getPasswordForUsername:self.username andServiceName:self.server.name error:&err];
	
	if (err) {
		[Logger error:@"Failed to load existing passphrase from secure keychain for server: %@", self.server.name];
	}
}

- (void)updateAndSaveConfigFile {
	self.cfg.username = self.username;
	
	[self.cfg.saveDict writeToFile:self.cfgFilePath atomically:YES];
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

- (void)saveUsername:(NSString *)username passphrase:(NSString *)passphrase {
	_username = username;
	_passphrase = passphrase;
	
	NSError *err = nil;
	BOOL saved = [STKeychain storeUsername:username andPassword:passphrase forServiceName:self.server.name updateExisting:YES error:&err];
	
	DAAlert *alert = nil;
	if (!saved || err) {
		NSString *fmt = NSLocalizedString(@"Failed to save new passphrase securely for server: %@", nil);
		alert = [DAAlert errorAlertWithMessage:[NSString stringWithFormat:fmt, self.server.name]];
		
	} else {
		alert = [DAAlert infoAlertWithMessage:NSLocalizedString(@"New SSH keys have been succesfully installed.", nil)];
		
		[self updateAndSaveConfigFile];
		
		[DAFlurry logWorkflowAction:WorkflowActionSSHKeysAdded];
	}
	
	[AlertQueue.queue enqueueAlert:alert];
}

- (void)deleteKeyFiles {
	[UIApplication.sharedApplication.fs removeItemAtPath:self.publicKeyPath error:nil];
	[UIApplication.sharedApplication.fs removeItemAtPath:self.privateKeyPath error:nil];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (1 == buttonIndex) {
		UITextField *usernameField = [alertView textFieldAtIndex:0];
		UITextField *passphraseField = [alertView textFieldAtIndex:1];
		
		[self saveUsername:usernameField.text passphrase:passphraseField.text];
	} else {
		[Logger info:@"SSH passphrase editing skiped with buttonIndex: %d", buttonIndex];
		[self deleteKeyFiles];
	}
	
	[NSNotificationCenter.defaultCenter postNotificationName:DASSHKeysStateChanged object:self];
}

@end
