//
//  DAAlert.m
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "Alert.h"
#import "Alert+Private.h"

@interface Alert ()
@property (strong, nonatomic, nonnull) NSString *title, *message;
@property (strong, nonatomic, readonly) NSMutableDictionary *userButtons;
@end

@implementation Alert {
	UIAlertController *_alertController;
}
@dynamic alertController;
@synthesize isFinished = _isFinished;
@synthesize isExecuting = _isExecuting;

- (nonnull id)initWithType:(AlertTypes)type {
	self = [self init];
	if (self) {
		_type = type;
		
		_userButtons = @[].mutableCopy;
	}
	return self;
}

+ (nonnull instancetype)alertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message {
	Alert *alert = [Alert.alloc initWithType:MessageAlert];
	
	alert.title = title;
	alert.message = message;
	
	return alert;
}

+ (nonnull instancetype)infoAlertWithMessage:(nonnull NSString *)message {
	return [self alertWithTitle:NSLocalizedString(@"Info", nil) message:message];
}

+ (nonnull instancetype)errorAlertWithMessage:(nonnull NSString *)message {
	return [self alertWithTitle:NSLocalizedString(@"Error", nil) message:message];
}
/*
+ (nonnull instancetype)loginAlertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message {
	Alert *alert = [Alert.alloc initWithType:LoginCredentialsAlert];
	
	alert.title = title;
	alert.message = message;
	
	return alert;
}*/

+ (nonnull instancetype)passwordAlertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message {
	Alert *alert = [Alert.alloc initWithType:PasswordAlert];
	
	alert.title = title;
	alert.message = message;
	
	return alert;
}

+ (nonnull instancetype)plainTextAlertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message {
	Alert *alert = [Alert.alloc initWithType:PlainTextAlert];
	
	alert.title = title;
	alert.message = message;
	
	return alert;
}

#pragma mark Concurrent operation

- (void)start {
	dispatch_async(dispatch_get_main_queue(), ^{
		_isExecuting = YES;
		[self showAlert];
	});
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isAsynchronous {
	return YES;
}

- (BOOL)isExecuting {
	return _isExecuting;
}

- (void)setIsExecuting:(BOOL)executing {
	[self willChangeValueForKey:isExecutingKeyPath];
	_isExecuting = executing;
	[self didChangeValueForKey:isExecutingKeyPath];
}

- (BOOL)isFinished {
	return _isFinished;
}

- (void)setIsFinished:(BOOL)finished {
	[self willChangeValueForKey:isFinishedKeyPath];
	_isFinished = finished;
	[self didChangeValueForKey:isFinishedKeyPath];
}

#pragma mark Properties

- (UIAlertController *)alertController {
	if (!_alertController) {
		_alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:UIAlertControllerStyleAlert];
	}
	
	return _alertController;
}

#pragma mark Presenting alerts

- (void)showAlert {
	NSDictionary *buttons = self.userButtons.copy;
	
	UIViewController *ctrl = UIApplication.sharedApplication.keyWindow.rootViewController;
	
	void (^dismissAction)(UIAlertAction * __nonnull) = ^(UIAlertAction * __nonnull alertAction) {
		[ctrl dismissViewControllerAnimated:YES completion:nil];
	};
	
	if (MessageAlert == self.type) {
		
	} else if (PasswordAlert == self.type) {
		for (UITextField *textField in self.alertController.textFields) {
			textField.secureTextEntry = YES;
		}
//		self.alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
		
		if (!buttons) {
			buttons = @{NSLocalizedString(@"Cancel", nil): dismissAction};
		}
//		[self.alertView addButtonWithTitle:];
		
	} else if (PlainTextAlert == self.type) {
		for (UITextField *textField in self.alertController.textFields) {
			textField.secureTextEntry = NO;
		}
//		self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
		
		if (!buttons) {
			buttons = @{NSLocalizedString(@"Cancel", nil): dismissAction};
		}
	/*} else if (LoginCredentialsAlert == self.type) {
		for (UITextField *textField in self.alertController.textFields) {
			textField.secureTextEntry = YES;
		}
		// TODO: Impl me - append text fields manually.
//		self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
		
		if (!buttons) {
			buttons = @[NSLocalizedString(@"Cancel", nil)];
		}
		*/
	} else if (CustomViewAlert == self.type) {
		[self showCustomAlert];
		return;
		
	} else {
		[LLog error:@"Failed to present Alert of Unknown type: %d", self.type];
	}
	
	for (NSString *title in buttons) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:buttons[title]];
		
		[self.alertController addAction:action];
	}
	
	// Default button.
	if (0 == self.alertController.actions.count) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:dismissAction];
		
		[self.alertController addAction:action];
	}
	
	[ctrl presentViewController:self.alertController animated:YES completion:nil];
}

- (void)addButtonWithTitle:(NSString *)title actionHandler:(void(^)(UIAlertAction *))handler {
	self.userButtons[title] = handler;
}

- (void)showCustomAlert {
	// Dummy.
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	self.isExecuting = NO;
	self.isFinished = YES;
}

#pragma mark Forwarding UIAlertViewDelegate

- (BOOL)respondsToSelector:(SEL)sel {
	if (@selector(alertView:didDismissWithButtonIndex:) == sel) {
		return YES;
	}
	return [self.delegate respondsToSelector:sel];
}

- (id)forwardingTargetForSelector:(SEL)sel {
	return [self.delegate respondsToSelector:sel] ? self.delegate : nil;
}

@end
