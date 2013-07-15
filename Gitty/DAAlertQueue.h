//
//  DAAlert.h
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAlert.h"

@interface DAAlertQueue : NSObject
+ (instancetype)manager;

- (void)enqueueAlert:(DAAlert *)alert;
@end
