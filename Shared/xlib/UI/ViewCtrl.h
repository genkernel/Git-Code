//
//  ViewCtrl.h
//  GestureWords
//
//  Created by apple on 19/01/12.
//  Copyright (c) 2012 AAV. All rights reserved.
//

#import "UI-Constants.h"
#import "UIView+Helper.h"

@interface ViewCtrl : UIViewController
+ (void)setNibPrefix:(NSString *)prefix;
+ (void)setDevicePostfix:(NSString *)postfix;

+ (instancetype)viewCtrl;
- (instancetype)initWithNib;
// Redefine and provide custom implementation in subclass to init ctrl.
//- (void)initCtrl;

- (UIImage *)screenshot;

@property (strong, nonatomic, readonly) NSFileManager *fm;
@property (strong, nonatomic, readonly) NSNotificationCenter *notificationCenter;

- (void)showErrorMessage:(NSString *)message;
- (void)showInfoMessage:(NSString *)message;
- (void)showWarnMessage:(NSString *)message;
- (void)showMessage:(NSString *)message withTitle:(NSString *)title;
- (void)showYesNoMessage:(NSString *)message withTitle:(NSString *)title;
@end
