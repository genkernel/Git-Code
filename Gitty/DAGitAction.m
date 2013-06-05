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
			[Logger error:@"Git action(%@) has finished successfully.", self.className];
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
