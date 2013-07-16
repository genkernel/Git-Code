//
//  DAAlert.m
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAlert.h"

@interface DAAlert ()
@property (strong, nonatomic) NSString *title, *message;

@property () BOOL isExecuting, isFinished;
@end

@implementation DAAlert {
	BOOL _isExecuting, _isFinished;
}
@synthesize isFinished = _isFinished;
@synthesize isExecuting = _isExecuting;

- (id)initWithType:(DAAlertTypes)type {
	self = [self init];
	if (self) {
		_type = type;
	}
	return self;
}

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message {
	DAAlert *alert = [DAAlert.alloc initWithType:DAMessageAlert];
	
	alert.title = title;
	alert.message = message;
	
	return alert;
}

+ (instancetype)infoAlertWithMessage:(NSString *)message {
	return [self alertWithTitle:NSLocalizedString(@"Info", nil) message:message];
}

+ (instancetype)errorAlertWithMessage:(NSString *)message {
	return [self alertWithTitle:NSLocalizedString(@"Error", nil) message:message];
}

+ (instancetype)passwordAlertWithTitle:(NSString *)title message:(NSString *)message {
	DAAlert *alert = [DAAlert.alloc initWithType:DAPasswordAlert];
	
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

#pragma mark Presenting alerts

- (void)showAlert {
	if (DAMessageAlert == self.type) {
		[self showMessageAlert];
	} else if (DAPasswordAlert == self.type) {
		[self showPasswordAlert];
	} else {
		[Logger error:@"Failed to present Alert of Unknown type: %d", self.type];
	}
}

- (void)showMessageAlert {
	UIAlertView *alert = [UIAlertView.alloc initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
	
	[alert show];
}

- (void)showPasswordAlert {
	UIAlertView *alert = [UIAlertView.alloc initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
	alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
	
	[alert show];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	self.isExecuting = NO;
	self.isFinished = YES;
}

#pragma mark Forwarding UIAlertViewDelegate

- (BOOL)respondsToSelector:(SEL)sel {
	if (@selector(alertView:didDismissWithButtonIndex:) == sel) {
		[Logger info:@"alertView:didDismissWithButtonIndex: catched."];
		return YES;
	}
	[Logger info:@"forwarding_test: %@", NSStringFromSelector(sel)];
	return [self.delegate respondsToSelector:sel];
}

- (id)forwardingTargetForSelector:(SEL)sel {
	return [self.delegate respondsToSelector:sel] ? self.delegate : nil;
}

@end
