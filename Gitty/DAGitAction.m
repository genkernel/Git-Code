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
	[Logger error:@"Dummy. %s", __PRETTY_FUNCTION__];
}

- (void)finilize {
	if (self.delegate.finishBlock) {
		[self notifyDelegate:^{
			self.delegate.finishBlock(self, self.completionError);
		}];
	} else {
		if (self.isCompletedSuccessfully) {
			[Logger warn:@"Git action(%@) has finished successfully.", self.className];
		} else {
			[Logger error:@"Git action(%@) failed with error: %@", self.className, self.completionError];
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


#pragma mark Static auth_cb helpers

int cred_acquire_userpass(git_cred **out,
						  const char *url,
						  const char *username_from_url,
						  unsigned int allowed_types,
						  void *payload)
{
	DAGitUser *user = (__bridge DAGitUser *)(payload);
	if (!user) {
		[Logger error:@"nil authentication user specified."];
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
	DAGitServer *server = (__bridge DAGitServer *)(payload);
	if (!server) {
		[Logger error:@"nil authentication server specified."];
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
