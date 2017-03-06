//
//  DAAlert.h
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "UI-Constants.h"

@class AlertQueue;

typedef enum {
	MessageAlert,
	PasswordAlert,
	PlainTextAlert,
//	LoginCredentialsAlert,
	CustomViewAlert
} AlertTypes;

@interface Alert : NSOperation <UIAlertViewDelegate> {
	BOOL _isExecuting, _isFinished;
}
+ (nonnull instancetype)alertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message;
+ (nonnull instancetype)infoAlertWithMessage:(nonnull NSString *)message;
+ (nonnull instancetype)errorAlertWithMessage:(nonnull NSString *)message;
//+ (nonnull instancetype)loginAlertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message;
+ (nonnull instancetype)passwordAlertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message;
+ (nonnull instancetype)plainTextAlertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message;

- (nonnull instancetype)initWithType:(AlertTypes)type;

- (void)addButtonWithTitle:(nonnull NSString *)title actionHandler:(nonnull void(^)(UIAlertAction * __nonnull))handler;

@property (weak, nonatomic, nullable) id<UIAlertViewDelegate> delegate;

@property (readonly) AlertTypes type;
@property (strong, nonatomic, readonly, nullable) UIAlertController *alertController;
//@property (weak, nonatomic, readonly) AlertQueue *alertQueue;

// Helpers.
@property (strong, nonatomic, readonly, nullable) NSString *editedPassword;
@end
