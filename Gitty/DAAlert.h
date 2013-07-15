//
//  DAAlert.h
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
//	DAMessageAlert,
	DAPasswordAlert
} DAAlertTypes;

@interface DAAlert : NSObject
//+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (instancetype)passwordAlertWithTitle:(NSString *)title message:(NSString *)message;

@property (readonly) DAAlertTypes type;
@end
