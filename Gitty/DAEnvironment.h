//
//  DAEnvironment.h
//  Gitty
//
//  Created by kernel on 17/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAEnvironment : NSObject
+ (instancetype)current;

@property (nonatomic, readonly) BOOL isDebug, isRelease;
@end
