//
//  DASshKeyInfoConfig.h
//  Gitty
//
//  Created by kernel on 10/11/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DynamicObject.h"

@interface DASshKeyInfoConfig : DynamicObject
@property (strong, nonatomic) NSString *username;

- (NSDictionary *)saveDict;
@end
