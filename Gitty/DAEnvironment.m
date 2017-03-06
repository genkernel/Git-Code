//
//  DAEnvironment.m
//  Gitty
//
//  Created by kernel on 17/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAEnvironment.h"

@implementation DAEnvironment

+ (instancetype)current {
	static id instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	
	return instance;
}

- (id)init {	
	self = [super init];
	if (self) {
#ifdef DEBUG
		_isDebug = YES;
#else
		_isRelease = YES;
#endif
	}
	return self;
}

@end
