//
//  DAAlert.h
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "CustomAlert.h"

@class Alert;


@interface AlertQueue : NSObject
+ (instancetype)queue;

- (void)enqueueAlert:(Alert *)alert;

@property (nonatomic, readonly) NSUInteger pendingAlertsCount;
@end
