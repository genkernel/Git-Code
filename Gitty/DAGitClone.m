//
//  DAGitClone.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitClone.h"
#import "DAGitManager+ActionsInterface.h"

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
	[self cloneRepoWithName:self.repoFullName fromServer:self.server];
}

- (BOOL)cloneRepoWithName:(NSString *)repoFullName fromServer:(DAGitServer *)server {
	// Remote.
	NSString *remotePath = [self.manager remotePathForRepoWithName:repoFullName atServer:server];
	NSURL *remoteURL = [NSURL URLWithString:remotePath];
	
	//	NSURL *url = [NSURL URLWithString:@"https://github.com/genkernel/AmazonCoverArt.git"];
	//NSURL *url = [NSURL URLWithString:@"git://github.com/genkernel/AmazonCoverArt.git"];
	
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
	
	void (^authenticateBlock)() = nil;
	{
		if (self.delegate.authenticationBlock) {
			authenticateBlock = ^{
				[self notifyDelegate:^{
					self.delegate.authenticationBlock();
				}];
			};
		} else {
			authenticateBlock = ^{
				[Logger info:@"authenticate"];
			};
		}
	}
	
	NSError *err = nil;
	_clonedRepo = [GTRepository cloneFromURL:remoteURL toWorkingDirectory:url
									  barely:YES withCheckout:YES error:&err
					   transferProgressBlock:transferProgressBlock checkoutProgressBlock:checkoutProgressBlock
						   authenticateBlock:authenticateBlock];
	
	_completionError = err;
	
	return self.clonedRepo && !self.completionError;
}

@end
