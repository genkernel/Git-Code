//
//  DABaseCtrl.m
//  Gitty
//
//  Created by kernel on 29/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@implementation DABaseCtrl
@dynamic git, servers, app;

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark Properties

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];
	
	[Logger error:@"Unknown segue specified: %@", segue.identifier];
}

- (DAGitManager *)git {
	return DAGitManager.manager;
}

- (DAServerManager *)servers {
	return DAServerManager.manager;
}

- (UIApplication *)app {
	return UIApplication.sharedApplication;
}

@end
