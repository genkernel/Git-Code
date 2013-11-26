//
//  DAGitClone.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitClone.h"
#import "DAGitManager+ActionsInterface.h"
#import "DAGitServer+Creation.h"

@interface DAGitClone ()
@property (strong, nonatomic) NSString *repoFullName;
@property (strong, nonatomic) DAGitServer *server;
@end

@implementation DAGitClone

+ (instancetype)cloneRepoWithName:(NSString *)name fromServer:(DAGitServer *)server {
	DAGitClone *clone = self.new;
	
	clone.repoFullName = name;
	clone.server = server;
	
	return clone;
}

- (void)exec {
	[self cloneRepoWithName:self.repoFullName fromServer:self.server authenticationUser:self.authenticationUser];
}

- (BOOL)cloneRepoWithName:(NSString *)repoFullName fromServer:(DAGitServer *)server authenticationUser:(DAGitUser *)user {
	// Remote.
	NSString *remotePath = [self.manager remotePathForRepoWithName:repoFullName atServer:server];
	NSURL *remoteURL = [NSURL URLWithString:remotePath];
	
	// Local.
	NSString *path = [self.manager localPathForRepoWithName:repoFullName atServer:server];
	
	if ([self.app.fs isDirectoryExistent:path]) {
		[Logger warn:@"Cleaning directory out before cloning: %@", path];
		[self.app.fs deleteDirectoryAndItsContents:path];
	}
	
	NSURL *url = [NSURL fileURLWithPath:path isDirectory:YES];
	
	void (^transferProgressBlock)(const git_transfer_progress *) = nil;
	{
		if (self.delegate.transferProgressBlock) {
			transferProgressBlock = ^(const git_transfer_progress *progress){
				[self notifyDelegate:^{
					self.delegate.transferProgressBlock(progress);
				}];
			};
		} else {
			transferProgressBlock = ^(const git_transfer_progress *progress){
				[Logger info:@"transferProgressBlock (%d). %d/%d", progress->received_bytes, progress->received_objects, progress->total_objects];
			};
		}
	}
	
	void (^checkoutProgressBlock)(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) = nil;
	{
		if (self.delegate.checkoutProgressBlock) {
			checkoutProgressBlock = ^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps){
				[self notifyDelegate:^{
					self.delegate.checkoutProgressBlock(path, completedSteps, totalSteps);
				}];
			};
		} else {
			checkoutProgressBlock = ^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
				[Logger info:@"checkoutProgressBlock"];
			};
		}
	}
	
	NSMutableDictionary *opts = @{GTRepositoryCloneOptionsBare: @(YES), GTRepositoryCloneOptionsCheckout: @(NO), GTRepositoryCloneOptionsTransportFlags: @(GTTransportFlagsNoCheckCert)}.mutableCopy;
	
	BOOL isSSH = [server.transferProtocol isEqualToString:SshTransferProtocol];
	
	BOOL hasServerKeys = NO;
	if (isSSH) {
		hasServerKeys = [DASshCredentials.manager hasSshKeypairSupportForServer:server];
	}
	
	GTCredentialProvider *credentials = nil;
	if (isSSH && hasServerKeys) {
		
		credentials = [GTCredentialProvider providerWithBlock:^GTCredential *(GTCredentialType type, NSString *URL, NSString *userName) {
			
			DASshKeyInfo *keysInfo = [DASshCredentials.manager keysForServer:server];
			
			NSString *username = keysInfo.username;
			NSString *passphrase = keysInfo.passphrase;
			
			NSString *publicKeyPath = keysInfo.publicKeyPath;
			NSString *privateKeyPath = keysInfo.privateKeyPath;
			
			NSURL *publicKeyUrl = [NSURL fileURLWithPath:publicKeyPath];
			NSURL *privateKeyUrl = [NSURL fileURLWithPath:privateKeyPath];
			
			return [GTCredential credentialWithUserName:username publicKeyURL:publicKeyUrl privateKeyURL:privateKeyUrl passphrase:passphrase error:nil];
		}];
		
		opts[GTRepositoryCloneOptionsCredentialProvider] = credentials;
		
	} else if (user) {
		
		credentials = [GTCredentialProvider providerWithBlock:^GTCredential *(GTCredentialType type, NSString *URL, NSString *userName) {
			
			 return [GTCredential credentialWithUserName:user.username password:user.password error:nil];
		}];
		
		opts[GTRepositoryCloneOptionsCredentialProvider] = credentials;
	}
	
	NSError *err = nil;
	_clonedRepo = [GTRepository cloneFromURL:remoteURL toWorkingDirectory:url options:opts error:&err transferProgressBlock:transferProgressBlock checkoutProgressBlock:checkoutProgressBlock];
	
	_completionError = err;
	
	return self.clonedRepo && !self.completionError;
}

@end
