//
//  UIDevice+Helper.h
//  MakeMyPlan
//
//  Created by kernel on 17/02/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "UI-Constants.h"

@interface UIDevice (Helper)
@property (nonatomic, readonly) BOOL isSimulator, isDevice;

@property (nonatomic, readonly) CGFloat systemVersionNumber;
@property (nonatomic, readonly) BOOL isIos6Family, isIos7Family, isIos8Family;
@property (nonatomic, readonly) BOOL isIos7FamilyOrGreater;
@property (nonatomic, readonly) BOOL isIos8FamilyOrGreater;

@property (strong, nonatomic, readonly) NSString *macAddress;
@end
