//
//  DASshKeyInfoConfig.m
//  Gitty
//
//  Created by kernel on 10/11/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DASshKeyInfoConfig.h"

@implementation DASshKeyInfoConfig
@dynamic username;

- (NSDictionary *)saveDict {
	return _storage.copy;
}

@end
