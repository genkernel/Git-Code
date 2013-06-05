//
//  DAServerManager.m
//  Gitty
//
//  Created by kernel on 30/11/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "DAServerManager.h"

@implementation DAServerManager

+ (instancetype)manager {
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
		// Load * servers list.
		NSString *path = [[NSBundle mainBundle] pathForResource:@"GitServers" ofType:@"plist"];
		NSArray *servers = [NSArray arrayWithContentsOfFile:path];

		NSMutableArray *items = [NSMutableArray arrayWithCapacity:servers.count];
		for (NSDictionary *dict in servers) {
			DAGitServer *server = [DAGitServer serverWithDictionary:dict];
			[items addObject:server];
		}
		_list = [NSArray arrayWithArray:items];
	}
	return self;
}

@end
