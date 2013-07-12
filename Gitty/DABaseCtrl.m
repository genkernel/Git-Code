//
//  DABaseCtrl.m
//  Gitty
//
//  Created by kernel on 29/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DABaseCtrl ()
@property (strong, nonatomic, readonly) NSMutableDictionary *cachedViews;
@end

@implementation DABaseCtrl
@dynamic git, servers, app;

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_cachedViews = NSMutableDictionary.new;
}

#pragma mark Public

- (void)cacheView:(UIView *)view withIdentifier:(NSString *)identifier {
	NSMutableSet *views = _cachedViews[identifier];
	if (!views) {
		views = NSMutableSet.new;
		_cachedViews[identifier] = views;
	}
	
	[views addObject:view];
}

- (UIView *)cachedViewWithIdentifier:(NSString *)identifier {
	NSMutableSet *views = _cachedViews[identifier];
	if (!views) {
		return nil;
	}
	
	UIView *v = views.anyObject;
	if (v) {
		[views removeObject:v];
	}
	return v;
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
