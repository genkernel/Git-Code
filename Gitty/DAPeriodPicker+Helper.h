//
//  DAPeriodPicker+Helper.h
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAPeriodPicker.h"
#import "DAPeriod.h"

@interface DAPeriodPicker (Helper)
- (DAPeriod *)noLimit;
- (DAPeriod *)today;
//- (NSTimeInterval)last3Days;
@end
