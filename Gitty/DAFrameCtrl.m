//
//  DAFrameCtrl.m
//  Gitty
//
//  Created by kernel on 21/09/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAFrameCtrl.h"
#import "DAFrameCtrl+States.h"
#import "DAFrameCtrl+Internal.h"

#import "DABaseCtrl.h"

static NSString *DefaultSegue = @"DefaultSegue";

@interface DAFrameCtrl ()
@property (strong, nonatomic, readonly) UIToolbar *overlayBluringToolbar;
@end

@implementation DAFrameCtrl

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];
	
	if ([segue.identifier isEqualToString:DefaultSegue]) {
		_mainCtrl = segue.destinationViewController;
	} else {
		[Logger warn:@"Unknown segue specified: %@", segue.identifier];
	}
}

- (NSUInteger)supportedInterfaceOrientations {
	BOOL isOverlayPresented = !self.overlayContainer.hidden;
	
	DABaseCtrl *presentedCtrl = isOverlayPresented ? self.overlayCtrl : self.mainCtrl;
	
	return presentedCtrl.supportedInterfaceOrientations;
}

- (void)applyLightEffectOfColor:(UIColor *)color {
	if (!self.overlayBluringToolbar) {
		_overlayBluringToolbar = [UIToolbar.alloc initWithFrame:self.overlayContainer.bounds];
	}
	
	self.overlayBluringToolbar.barTintColor = color;
	[self.overlayContainer.layer insertSublayer:self.overlayBluringToolbar.layer atIndex:0];
}

- (void)presentOverlayCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated animationOption:(DAFramePresentingAnimations)option {
	if (self.overlayCtrl) {
		[Logger error:@"Another Overlay ctrl is currently presented."];
		[Logger error:@"Dismiss current Overlay ctrl before presenting new one."];
		return;
	}
	_overlayCtrl = ctrl;
	
	[self presentOverlayContainerWithOption:option];
}

- (void)dismissOverlayCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated {
	[self.overlayCtrl willMoveToParentViewController:nil];
	
	[self animateOverlayContainerWithOption:ctrl.presentationOption completionHandler:^(BOOL finished) {
		[self.overlayContainer removeAllSubviews];
		
		[self.overlayCtrl didMoveToParentViewController:nil];
		
		_overlayCtrl = nil;
	}];
}

#pragma mark Animation

- (void)presentOverlayContainerWithOption:(DAFramePresentingAnimations)option {
	[self prepositionOverlayContainerForOption:option];
	
	[self applyLightEffectOfColor:UIColor.bluringColor];
	
	[self addChildViewController:self.overlayCtrl];
	
	self.overlayCtrl.view.frame = self.overlayContainer.bounds;
	[self.overlayContainer addSubview:self.overlayCtrl.view];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self animateOverlayContainerWithOption:DASlideToCenterPresentation completionHandler:^(BOOL finished) {
			[self.overlayCtrl didMoveToParentViewController:self];
		}];
	});
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	BOOL isOverlayPresented = !self.overlayContainer.hidden;
	return isOverlayPresented ? self.overlayCtrl : self.mainCtrl;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
	BOOL isOverlayPresented = !self.overlayContainer.hidden;
	return isOverlayPresented ? self.overlayCtrl : self.mainCtrl;
}

- (void)prepositionOverlayContainerForOption:(DAFramePresentingAnimations)option {
	CGFloat alpha = 1;
	CGPoint p = CGPointZero;
	
	if (DAAlphaFadePresentation == option) {
		alpha = 0;
	} else {
		p = [self marginsForOption:option];
	}
	
	self.overlayContainer.alpha = alpha;
	
	NSArray *overlayConstraints = @[self.overlayLeft, self.overlayRight, self.overlayTop, self.overlayBottom];
	
	[self.view removeConstraints:overlayConstraints];
	{
		self.overlayLeft.constant = p.x;
		self.overlayRight.constant = -p.x;
		
		self.overlayTop.constant = p.y;
		self.overlayBottom.constant = -p.y;
	}
	[self.view addConstraints:overlayConstraints];
	
	[self.overlayContainer.superview layoutIfNeeded];
}

- (void)animateOverlayContainerWithOption:(DAFramePresentingAnimations)option completionHandler:(void(^)(BOOL))completionHandler {
	self.overlayContainer.hidden = NO;
	
	CGPoint p = [self marginsForOption:option];
	CGFloat alpha = [self alphaForOption:option];
	
	self.overlayLeft.constant = p.x;
	self.overlayRight.constant = -p.x;
	
	self.overlayTop.constant = p.y;
	self.overlayBottom.constant = -p.y;
	
	[UIView animateWithDuration:SmoothAnimationDuration delay:0 usingSpringWithDamping:1 initialSpringVelocity:.6 options:UIViewAnimationOptionCurveLinear animations:^{
		
		self.overlayContainer.alpha = alpha;
		[self.overlayContainer.superview layoutIfNeeded];
		
		[self setNeedsStatusBarAppearanceUpdate];
	}completion:completionHandler];
}

@end
