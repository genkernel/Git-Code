//
//  DAFilterPeriod.h
//  Gitty
//
//  Created by kernel on 23/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAPeriod : NSObject
+ (instancetype)periodWithTitle:(NSString *)title;

@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSDate *date;
@end
