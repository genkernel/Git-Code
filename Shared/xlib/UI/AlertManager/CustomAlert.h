//
//  CustomAlert.h
//  Gitty
//
//  Created by kernel on 23/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "Alert.h"
#import "AlertCtrl.h"

@interface CustomAlert : Alert
+ (instancetype)alertPresentingCtrl:(AlertCtrl *)ctrl animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL)animated;
@end
