//
//  DAGitAction.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitAction.h"
#import "DAGitAction+ManagerAccess.h"
#import "DAGitManager+ActionsInterface.h"

@implementation DAGitAction
// Synthesize explicitly for @protected ivars (not synthesized auto by compiler).
@synthesize completionError = _completionError;
@dynamic app, isCompletedSuccessfully;

- (void)exec {
	[LLog error:@"Dummy. %s", __PRETTY_FUNCTION__];
}

- (void)finilize {
	if (self.delegate.finishBlock) {
		[self notifyDelegate:^{
			self.delegate.finishBlock(self, self.completionError);
		}];
	} else {
		if (self.isCompletedSuccessfully) {
			[LLog warn:@"Git action(%@) has finished successfully.", self.className];
		} else {
			[LLog error:@"Git action(%@) failed with error: %@", self.className, self.completionError];
		}
	}
}

- (void)notifyDelegate:(void(^)())block {
	dispatch_async(self.delegateQueue, block);
}

#pragma mark Properties

- (UIApplication *)app {
	return UIApplication.sharedApplication;
}

- (BOOL)isCompletedSuccessfully {
	return !self.completionError;
}

@end

/*
#pragma mark Static auth_cb helpers

int cred_acquire_userpass(git_cred **out,
						  const char *url,
						  const char *username_from_url,
						  unsigned int allowed_types,
						  void *payload)
{
	DAGitUser *user = (__bridge DAGitUser *)(payload);
	if (!user) {
		[LLog error:@"nil authentication user specified."];
		return GIT_EUSER;
	}
	
	return git_cred_userpass_plaintext_new(out, user.username.UTF8String, user.password.UTF8String);
}

int cred_acquire_ssh(git_cred **out,
					 const char *url,
					 const char *username_from_url,
					 unsigned int allowed_types,
					 void *payload)
{
	DASshKeyInfo *keysInfo = nil;
	
	DAGitServer *server = (__bridge DAGitServer *)(payload);
	if (server) {
		keysInfo = [DASshCredentials.manager keysForServer:server];
	} else {
		return GIT_ENOTFOUND;
//		keysInfo = DASshCredentials.manager.globalKeys;
	}
	
#ifdef GIT_SSH
	NSString *username = keysInfo.username;
	NSString *passphrase = keysInfo.passphrase;
	
	NSString *publicKeyPath = keysInfo.publicKeyPath;
	NSString *privateKeyPath = keysInfo.privateKeyPath;
	
	return git_cred_ssh_keyfile_passphrase_new(out, username.UTF8String, publicKeyPath.UTF8String, privateKeyPath.UTF8String, passphrase.UTF8String);
#else
#warning GIT_SSH is not implemented.
	return GIT_ERROR;
#endif
}*/
