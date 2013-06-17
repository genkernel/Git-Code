//
//  DAGitServer.m
//  Gitty
//
//  Created by kernel on 30/11/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "DAGitServer.h"
#import "DAGitServer+Creation.h"

@implementation DAGitServer
@dynamic saveDict;

+ (instancetype)serverWithDictionary:(NSDictionary *)dict {
	return [self.alloc initWithDictionary:dict];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	self = [self init];
	if (self) {
		_name = dict[ServerName];
		_gitBaseUrl = dict[ServerGitBaseUrl];
		_saveDirectoryName = dict[SaveDirectory];
		_logoIconName = dict[LogoIcon];
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"[%@, 0x%X]", self.name, (int)self];
}

- (NSDictionary *)saveDict {
	return @{ServerName: self.name,
			 ServerGitBaseUrl: self.gitBaseUrl,
			 SaveDirectory: self.saveDirectoryName,
			 LogoIcon: self.logoIconName};
}

@end
