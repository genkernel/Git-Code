//
//  DAGravatar.m
//  Gitty
//
//  Created by kernel on 24/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGravatar.h"

static NSString *baseUrl = @"https://secure.gravatar.com/avatar/";

@implementation DAGravatar

+ (instancetype)manager {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	return instance;
}

- (NSURL *)getUrlForEmail:(NSString *)email {
	NSString *hash = [Cryptor md5ForString:email];
	NSString *str = [baseUrl stringByAppendingString:hash];
	return [NSURL URLWithString:str];
}

@end
