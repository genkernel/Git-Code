//
//  NavViewCtrl.m
//  Gitty
//
//  Created by kernel on 17/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "NavViewCtrl.h"

@implementation NavViewCtrl

- (BOOL)prefersStatusBarHidden {
	return self.topViewController.prefersStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
	return self.topViewController.preferredStatusBarUpdateAnimation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.topViewController.preferredStatusBarStyle;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
	return self.topViewController;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
