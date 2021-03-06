//
//  DABaseCtrl.m
//  Gitty
//
//  Created by kernel on 29/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"
#import "DABaseCtrl+Internal.h"

#import "DAFrameCtrl+Internal.h"

@interface DABaseCtrl ()
@property (strong, nonatomic, readonly) NSMutableDictionary *cachedViews;
@end

@implementation DABaseCtrl
@dynamic git, servers, app, frameCtrl;
@dynamic isMenuPresented, isOverlayPresented;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];
	
	[LLog error:@"Unknown segue specified: %@", segue.identifier];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_cachedViews = NSMutableDictionary.new;
}

// Override
- (void)presentViewController:(DABaseCtrl *)ctrl animated:(BOOL)flag completion:(void (^)(void))completion {
	if (completion) {
		ctrl.presentedAction = ^{
			completion();
		};
	}
	
	[self.frameCtrl presentOverlayCtrl:ctrl animated:flag animationOption:ctrl.presentationOption];
}

// Override
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
	if (completion) {
		self.frameCtrl.overlayCtrl.dismissedAction = ^{
			completion();
		};
	}
	
	[self.frameCtrl dismissOverlayCtrl:self.frameCtrl.overlayCtrl animated:flag];
}

- (void)presentMenuCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated animationOption:(DAFramePresentingAnimations)option {
	[self.frameCtrl presentMenuCtrl:ctrl animated:animated animationOption:option];
}

- (void)dismissPresentedMenuAnimated:(BOOL)animated {
	[self.frameCtrl dismissMenuCtrl:self.frameCtrl.menuCtrl animated:animated];
}

- (id<UIViewControllerAnimatedTransitioning>)animatedTransitioningForOperation:(UINavigationControllerOperation)operation {
	return nil;
}

#pragma mark AMWaveTransitioning

- (NSArray *)visibleCells {
	return nil;
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

- (DAGitManager *)git {
	return DAGitManager.manager;
}

- (DAServerManager *)servers {
	return DAServerManager.manager;
}

- (UIApplication *)app {
	return UIApplication.sharedApplication;
}

- (DAFrameCtrl *)frameCtrl {
	if ([self.parentViewController isKindOfClass:DAFrameCtrl.class]) {
		return (DAFrameCtrl *)self.parentViewController;
	} else {
		return (DAFrameCtrl *)self.navigationController.parentViewController;
	}
}

- (BOOL)isMenuPresented {
	return self.frameCtrl.menuCtrl != nil;
}

- (BOOL)isOverlayPresented {
	return self.frameCtrl.overlayCtrl != nil;
}

@end
