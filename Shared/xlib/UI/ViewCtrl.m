//
//  ViewCtrl.m
//  GestureWords
//
//  Created by apple on 19/01/12.
//  Copyright (c) 2012 AAV. All rights reserved.
//

#import "ViewCtrl.h"

#import "AlertQueue.h"

static NSString *nibPrefix = @"";
static NSString *devicePostfix = @"";

@implementation ViewCtrl
@dynamic fm, notificationCenter;

+ (instancetype)viewCtrl {
	return [self.alloc initWithNib];
}

+ (void)setNibPrefix:(NSString*)prefix {
	nibPrefix = [[NSString alloc] initWithString:prefix];
}

+ (void)setDevicePostfix:(NSString*)postfix {
	devicePostfix = [[NSString alloc] initWithString:postfix];
}

#pragma mark Instance methods

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNib {
	NSString *className = self.className;
	NSString *superclassName = self.superclass.className;
	
	NSString *name = [NSString stringWithFormat:@"%@%@%@", nibPrefix, className, devicePostfix];
	
	if ([self isNibExistent:name]) {
		self = [super initWithNibName:name bundle:nil];
		return self;
	}
	
	// Try superclass name.
	name = [NSString stringWithFormat:@"%@%@%@", nibPrefix, superclassName, devicePostfix];
	
	if ([self isNibExistent:name]) {
		self = [super initWithNibName:name bundle:nil];
		return self;
	}
	
	// Try with no prefix or postfix in name.
	if ([self isNibExistent:className]) {
		self = [super initWithNibName:className bundle:nil];
		return self;
	}
	
	// Try superclass with no prefix or postfix in name.
	if ([self isNibExistent:superclassName]) {
		self = [super initWithNibName:superclassName bundle:nil];
		return self;
	}
	
	[LLog warn:@"WARN. No Xib file found for view ctrl: %@.", self.className];
	self = [self init];
	
	return self;
}

- (BOOL)isNibExistent:(NSString *)name {
	return [[NSBundle mainBundle] pathForResource:name ofType:@"nib"] != nil;
}

#pragma mark View lifecycle

//- (void)initCtrl {
//	// Dummy impl. Redefine in subclass.
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

#pragma mark Helpers

- (UIImage *)screenshot {
	return self.view.screeshotWithCurrentContext;
}

- (void)showYesNoMessage:(NSString *)message withTitle:(NSString *)title {
	NSArray *buttons = @[NSLocalizedString(@"No", nil), NSLocalizedString(@"Yes", nil)];
	
	Alert *alert = [Alert alertWithTitle:title message:message];
	alert.delegate = self;
	
	__weak Alert *localAlert = alert;
	
	for (NSString *title in buttons) {
		[alert addButtonWithTitle:title actionHandler:^(UIAlertAction * __nonnull alertAction) {
			[localAlert.alertController dismissViewControllerAnimated:YES completion:nil];
		}];
	}
	
	[AlertQueue.queue enqueueAlert:alert];
}

- (void)showMessage:(NSString *)message withTitle:(NSString *)title {
	Alert *alert = [Alert alertWithTitle:title message:message];
	
	alert.delegate = self;
	
	[AlertQueue.queue enqueueAlert:alert];
}

- (void)showErrorMessage:(NSString *)message {
	[self showMessage:message withTitle:NSLocalizedString(@"Error", @"")];
}

- (void)showInfoMessage:(NSString *)message {
	[self showMessage:message withTitle:NSLocalizedString(@"Information", @"")];
}

- (void)showWarnMessage:(NSString *)message {
	[self showMessage:message withTitle:NSLocalizedString(@"Warning", @"")];
}

#pragma mark Properties

- (NSFileManager *)fm {
	return NSFileManager.defaultManager;
}

- (NSNotificationCenter *)notificationCenter {
	return NSNotificationCenter.defaultCenter;
}

@end
