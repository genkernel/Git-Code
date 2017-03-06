//
//  DAGitPull.m
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitPull.h"
#import <ObjectiveGit/git2/errors.h>

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
	BOOL success = [self pullFromServer:self.server];
	
	if (!success) {
		NSString *desc = [NSString stringWithFormat:@"Pull failed for %@ server.\n\nCheck your network connection.", self.server.name];
		
		NSDictionary *info = @{NSLocalizedDescriptionKey: desc};
		_completionError = [NSError errorWithDomain:@"libgit2" code:0 userInfo:info];
	}
}

- (git_error_code)pullFromServer:(DAGitServer *)server {
	NSError *err = nil;
	GTConfiguration *cfg = [self.repo configurationWithError:&err];
	if (err) {
		[LLog error:@"Failed to obtain Configuration obj for Repo."];
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
	
	return [self.repo pullFromRemote:remote credentials:credentials];
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
