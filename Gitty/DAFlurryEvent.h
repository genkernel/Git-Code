//
//  DAFlurryEvent.h
//  Gitty
//
//  Created by kernel on 2/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAFlurryEvent : NSObject
+ (instancetype)eventWithName:(NSString *)name;
+ (instancetype)eventWithName:(NSString *)name params:(NSDictionary *)params;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *params;
@end
