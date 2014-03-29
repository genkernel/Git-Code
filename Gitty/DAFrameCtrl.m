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
static NSString *MenuNavSegue = @"MenuNavSegue";
static NSString *OverlayNavSegue = @"OverlayNavSegue";

@interface DAFrameCtrl ()
@property (strong, nonatomic, readonly) UIToolbar *overlayBluringToolbar;

@property (strong, nonatomic, readonly) NavViewCtrl *menuNavCtrl, *overlayNavCtrl;

@property (strong, nonatomic, readonly) DABaseCtrl *presentedCtrl;
@end

@implementation DAFrameCtrl
@dynamic presentedCtrl;

- (BOOL)prefersStatusBarHidden {
	return self.presentedCtrl.prefersStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
	return self.presentedCtrl.preferredStatusBarUpdateAnimation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.presentedCtrl.preferredStatusBarStyle;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];
	
	if ([segue.identifier isEqualToString:DefaultSegue]) {
		_mainCtrl = segue.destinationViewController;
		
	} else if ([segue.identifier isEqualToString:MenuNavSegue]) {
		_menuNavCtrl = segue.destinationViewController;
		
	} else if ([segue.identifier isEqualToString:OverlayNavSegue]) {
		_overlayNavCtrl = segue.destinationViewController;
		
	} else {
		[Logger warn:@"Unknown segue specified: %@", segue.identifier];
	}
}

- (DABaseCtrl *)presentedCtrl {
	BOOL isOverlayPresented = self.overlayCtrl != nil;
	BOOL isMenuPresented = self.menuCtrl != nil;
	
	return isOverlayPresented ? self.overlayCtrl : (isMenuPresented ? self.menuCtrl : self.mainCtrl);
}

- (NSUInteger)supportedInterfaceOrientations {
	return self.presentedCtrl.supportedInterfaceOrientations;
}

- (void)applyLightEffectOfColor:(UIColor *)color {
	if (!self.overlayBluringToolbar) {
		_overlayBluringToolbar = [UIToolbar.alloc initWithFrame:self.overlayContainer.bounds];
	}
	
	self.overlayBluringToolbar.barTintColor = color;
	[self.overlayContainer.layer insertSublayer:self.overlayBluringToolbar.layer atIndex:0];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.presentedCtrl;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
	return self.presentedCtrl;
}

#pragma mark Overlay

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
	[self animateOverlayContainerWithOption:ctrl.presentationOption completionHandler:^(BOOL finished) {
		self.overlayContainer.hidden = YES;
		
		_overlayCtrl = nil;
		self.overlayNavCtrl.viewControllers = @[];
		
		[self setNeedsStatusBarAppearanceUpdate];
	}];
}

#pragma mark Overlay Animation

- (void)presentOverlayContainerWithOption:(DAFramePresentingAnimations)option {
	[self prepositionOverlayContainerForOption:option];
	
	[self applyLightEffectOfColor:UIColor.bluringColor];
	
	self.overlayNavCtrl.navigationBarHidden = NO;
	[self.overlayNavCtrl setViewControllers:@[self.overlayCtrl]];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self animateOverlayContainerWithOption:DASlideToCenterPresentation completionHandler:^(BOOL finished) {
		}];
	});
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
		
	}completion:^(BOOL finished) {
		if (completionHandler) {
			completionHandler(finished);
		}
	}];
}

#pragma mark Menu

- (void)presentMenuCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated animationOption:(DAFramePresentingAnimations)option {
	if (self.menuCtrl) {
		[Logger error:@"Another Menu ctrl is currently presented."];
		[Logger error:@"Dismiss current Menu ctrl before presenting new one."];
		return;
	}
	_menuCtrl = ctrl;
	
	[self presentMenuContainerWithOption:option];
}

- (void)dismissMenuCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated {
	[self animateMenuContainerWithOption:DASlideToCenterPresentation completionHandler:^(BOOL finished) {
		_menuCtrl = nil;
		self.menuNavCtrl.viewControllers = @[];
		
		[self setNeedsStatusBarAppearanceUpdate];
		
		self.dismissMainOverlay.hidden = YES;
	}];
}

#pragma mark Menu Animation

- (void)presentMenuContainerWithOption:(DAFramePresentingAnimations)option {
	[self prepositionMenuContainerForOption:DASlideToCenterPresentation];
	
	self.menuNavCtrl.navigationBarHidden = NO;
	[self.menuNavCtrl setViewControllers:@[self.menuCtrl]];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self animateMenuContainerWithOption:option completionHandler:^(BOOL finished) {
			self.dismissMainOverlay.hidden = NO;
		}];
	});
}

- (void)prepositionMenuContainerForOption:(DAFramePresentingAnimations)option {
	CGFloat alpha = 1;
	CGPoint p = CGPointZero;
	
	if (DAAlphaFadePresentation == option) {
		alpha = 0;
	} else {
		p = [self marginsForOption:option];
	}
	
	self.menuContainer.alpha = alpha;
	
	NSArray *constraints = @[self.mainLeft, self.mainRight, self.mainTop, self.mainBottom];
	
	[self.view removeConstraints:constraints];
	{
		self.mainLeft.constant = p.x;
		self.mainRight.constant = -p.x;
		
		self.mainTop.constant = p.y;
		self.mainBottom.constant = -p.y;
	}
	[self.view addConstraints:constraints];
	
	[self.mainContainer.superview layoutIfNeeded];
}

- (void)animateMenuContainerWithOption:(DAFramePresentingAnimations)option completionHandler:(void(^)(BOOL))completionHandler {
	
	CGPoint p = [self menuMarginsForOption:option];
	CGFloat alpha = [self menuAlphaForOption:option];
	
	NSArray *constaints = @[self.mainLeft, self.mainTop, self.mainRight, self.mainBottom];
	
	[self.mainContainer.superview removeConstraints:constaints];
	{
		self.mainLeft.constant = p.x;
		self.mainRight.constant = -p.x;
		
		self.mainTop.constant = p.y;
		self.mainBottom.constant = -p.y;
	}
	[self.mainContainer.superview addConstraints:constaints];
	
	[UIView animateWithDuration:SmoothAnimationDuration delay:0 usingSpringWithDamping:1 initialSpringVelocity:.6 options:UIViewAnimationOptionCurveLinear animations:^{
		
		self.mainContainer.alpha = alpha;
		[self.mainContainer.superview layoutIfNeeded];
		
	}completion:^(BOOL finished) {
		if (completionHandler) {
			completionHandler(finished);
		}
	}];
}

#pragma mark Actions

- (IBAction)dismissMenuPressed:(UIButton *)sender {
	[self dismissMenuCtrl:self.menuCtrl animated:YES];
}

@end
