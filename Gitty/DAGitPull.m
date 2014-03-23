//
//  DAGitPull.m
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitPull.h"

//static int transferProgressCallback(const git_transfer_progress *progress, void *payload);

@interface DAGitPull ()
@property (strong, nonatomic) GTRepository *repo;
@property (strong, nonatomic) DAGitServer *server;
@end

@implementation DAGitPull

+ (instancetype)pullForRepository:(GTRepository *)repo fromServer:(DAGitServer *)server {
	DAGitPull *pull = self.new;
	pull.repo = repo;
	pull.server = server;
	
	return pull;
}

- (void)exec {
	int code = [self pullFromServer:self.server];
	
	if (GIT_EEXISTS == code) {
		NSDictionary *info = @{NSLocalizedDescriptionKey: @"Repo is up to date."};
		_completionError = [NSError errorWithDomain:@"libgit2" code:code userInfo:info];
	} else if (GIT_OK != code) {
		NSString *desc = [NSString stringWithFormat:@"Pull failed for %@ server.\n\nCheck your network connection.", self.server.name];
		
		NSDictionary *info = @{NSLocalizedDescriptionKey: desc};
		_completionError = [NSError errorWithDomain:@"libgit2" code:code userInfo:info];
	}
}

- (int)pullFromServer:(DAGitServer *)server {
	NSError *err = nil;
	GTConfiguration *cfg = [self.repo configurationWithError:&err];
	if (err) {
		[Logger error:@"Failed to obtain Configuration obj for Repo."];
		assert(NO);
	}
	
	GTRemote *remote = cfg.remotes.lastObject;
	
	BOOL isSSH = [server.transferProtocol isEqualToString:SshTransferProtocol];
	
	BOOL hasServerKeys = NO;
	if (isSSH) {
		hasServerKeys = [DASshCredentials.manager hasSshKeypairSupportForServer:server];
	}
	
	DAGitUser *user = self.authenticationUser;
	
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
		
	} else if (user) {
		
		credentials = [GTCredentialProvider providerWithBlock:^GTCredential *(GTCredentialType type, NSString *URL, NSString *userName) {
			
			return [GTCredential credentialWithUserName:user.username password:user.password error:nil];
		}];
	}
	
	[self.repo pullFromRemote:remote credentials:credentials];
	
	return 0;
}

@end
/*
static int transferProgressCallback(const git_transfer_progress *progress, void *payload) {
	if (!payload) {
		return 0;
	}
	
	void (^block)(const git_transfer_progress *) = (__bridge id)payload;
	block(progress);
	
	return 0;
}*/
