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
	
	BOOL isSSH = [server.transferProtocol isEqualToString:SshTransferProtocol];
	git_cred_acquire_cb auth_cb = isSSH ? cred_acquire_ssh : cred_acquire_userpass;
	
	id payloadObject = user;
	if (isSSH) {
		BOOL hasServerKeys = [DASshCredentials.manager hasSshKeypairSupportForServer:server];
		payloadObject = hasServerKeys ? server : nil;
	}
	
	NSError *err = nil;
	_clonedRepo = [GTRepository cloneFromURL:remoteURL toWorkingDirectory:url
									  barely:YES withCheckout:NO error:&err
					   transferProgressBlock:transferProgressBlock checkoutProgressBlock:checkoutProgressBlock
				   authenticationCallback:auth_cb authenticationPayload:(__bridge void *)payloadObject];
	
	_completionError = err;
	
	return self.clonedRepo && !self.completionError;
}

@end
