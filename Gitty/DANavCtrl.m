//
//  DANavCtrl.m
//  Gitty
//
//  Created by Shawn Altukhov on 27/04/2014.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DANavCtrl.h"
#import "DABaseCtrl.h"

@interface DANavCtrl () <UINavigationControllerDelegate>
@end

@implementation DANavCtrl

- (void)dealloc {
	self.delegate = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.delegate = self;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(DABaseCtrl *)fromVC toViewController:(DABaseCtrl *)toVC {
	
	return [toVC animatedTransitioningForOperation:operation];
}

@end
