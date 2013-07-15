//
//  DAAlert.m
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAlert.h"

@implementation DAAlert
//+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message;

+ (instancetype)passwordAlertWithTitle:(NSString *)title message:(NSString *)message {
	return self.new;
}

@end
