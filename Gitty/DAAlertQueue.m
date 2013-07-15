//
//  DAAlert.m
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAlertQueue.h"

@implementation DAAlertQueue

+ (instancetype)manager {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	return instance;
}

- (void)enqueueAlert:(DAAlert *)alert {
	
}

@end
