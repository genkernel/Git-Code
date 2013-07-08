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

static NSString *sshTransferProtocol = @"ssh://";

static int cred_acquire_userpass(git_cred **, const char *, const char *, unsigned int, void *);
static int cred_acquire_ssh(git_cred **out, const char *url, const char *username_from_url, unsigned int allowed_types, void *payload);

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
	
//	remoteURL = [NSURL URLWithString:@"https://github.com/genkernel/TreeView.git"];
	
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
	
	BOOL isSSH = [server.transferProtocol isEqualToString:sshTransferProtocol];
	id payloadObject = isSSH ? server : user;
	git_cred_acquire_cb auth_cb = isSSH ? cred_acquire_ssh : cred_acquire_userpass;
	
	NSError *err = nil;
	_clonedRepo = [GTRepository cloneFromURL:remoteURL toWorkingDirectory:url
									  barely:YES withCheckout:NO error:&err
					   transferProgressBlock:transferProgressBlock checkoutProgressBlock:checkoutProgressBlock
				   authenticationCallback:auth_cb authenticationPayload:(__bridge void *)payloadObject];
	
	_completionError = err;
	
	return self.clonedRepo && !self.completionError;
}

@end

#pragma mark Static auth_cb helpers

static int cred_acquire_userpass(git_cred **out,
						const char *url,
						const char *username_from_url,
						unsigned int allowed_types,
						void *payload)
{
	DAGitUser *user = (__bridge DAGitUser *)(payload);
	if (!user) {
		return GIT_EUSER;
	}
	
	return git_cred_userpass_plaintext_new(out, user.username.UTF8String, user.password.UTF8String);
}

static int cred_acquire_ssh(git_cred **out,
							const char *url,
							const char *username_from_url,
							unsigned int allowed_types,
							void *payload)
{
	DAGitServer *server = (__bridge DAGitServer *)(payload);
	if (!server) {
		return GIT_ENOTFOUND;
	}
	
#ifdef GIT_SSH
	NSString *passphrase = DASshCredentials.manager.passphrase;
	
	NSString *publicKeyPath = DASshCredentials.manager.publicKeyPath;
	NSString *privateKeyPath = DASshCredentials.manager.privateKeyPath;
	
	return git_cred_ssh_keyfile_passphrase_new(out, publicKeyPath.UTF8String, privateKeyPath.UTF8String, passphrase.UTF8String);
#else
#warning GIT_SSH is not implemented.
	return GIT_ERROR;
#endif
}
