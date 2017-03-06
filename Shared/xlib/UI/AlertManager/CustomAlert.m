//
//  CustomAlert.m
//  Gitty
//
//  Created by kernel on 23/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "CustomAlert.h"
#import "Alert+Private.h"
#import "CustomAlert+Private.h"

@interface CustomAlert ()
@property (nonatomic) BOOL presentAnimated;
@end

@implementation CustomAlert

+ (instancetype)alertPresentingCtrl:(AlertCtrl *)ctrl animated:(BOOL)animated {
	CustomAlert *alert = [CustomAlert.alloc initWithType:CustomViewAlert];
	alert.presentAnimated = animated;
	
	[alert loadCtrl:ctrl];
	
	return alert;
}

- (void)loadCtrl:(AlertCtrl *)ctrl {
	UIWindowLevel CustomAlertWindowLevel = UIWindowLevelAlert - 500;
	
	_window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];
	self.window.windowLevel = CustomAlertWindowLevel;
	
	self.window.rootViewController = ctrl;
	
	ctrl.alertPresenter = self;
}

- (void)showCustomAlert {
	self.window.alpha = 0;
	
	[self.window makeKeyAndVisible];
	
	if (self.presentAnimated) {
		[UIView animateWithDuration:SmoothAnimationDuration animations:^{
			self.window.alpha = 1;
		}];
	} else {
		self.window.alpha = 1;
	}
}

- (void)dismissAnimated:(BOOL)animated {
	NSTimeInterval duration = animated ? SmoothAnimationDuration : .0;
	
	[UIView animateWithDuration:duration animations:^{
		self.window.alpha = 0;
		
	}completion:^(BOOL finished) {
		_window = nil;
		
		self.isExecuting = NO;
		self.isFinished = YES;
	}];
}

@end
