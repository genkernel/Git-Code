//
//  DAServerManager.m
//  Gitty
//
//  Created by kernel on 30/11/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "DAServerManager.h"

static NSString *StoreFilename = @"GitServers.plist";

@interface DAServerManager ()
@property (strong, nonatomic, readonly) NSString *storePath;
@end

@implementation DAServerManager {
	NSMutableDictionary *_namedList;
}
@dynamic list;
@synthesize namedList = _namedList;
@dynamic storePath;

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
		[self copyInitialStoreFileIfNeeded];
		
		NSArray *servers = [NSArray arrayWithContentsOfFile:self.storePath];

		NSMutableDictionary *items = [NSMutableDictionary dictionaryWithCapacity:servers.count];
		for (NSDictionary *dict in servers) {
			DAGitServer *server = [DAGitServer serverWithDictionary:dict];
			items[server.name] = server;
		}
		_namedList = [NSMutableDictionary dictionaryWithDictionary:items];
	}
	return self;
}

- (void)addNewServer:(DAGitServer *)server {
	_namedList[server.name] = server;
	
	NSMutableArray *saveArr = [NSMutableArray arrayWithCapacity:self.namedList.count];
	for (DAGitServer *saveServer in self.list) {
		[saveArr addObject:saveServer.saveDict];
	}
	[saveArr writeToFile:self.storePath atomically:YES];
}

#pragma mark Properties

- (NSArray *)list {
	return self.namedList.allValues;
}

- (NSString *)storePath {
	return [UIApplication.sharedApplication.documentsPath stringByAppendingPathComponent:StoreFilename];
}

#pragma mark Internals

- (void)copyInitialStoreFileIfNeeded {
	NSFileManager *fs = UIApplication.sharedApplication.fs;
	if ([fs isFileExistent:self.storePath]) {
		return;
	}
	
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:StoreFilename.stringByDeletingPathExtension ofType:StoreFilename.pathExtension];
	[fs copyItemAtPath:bundlePath toPath:self.storePath error:nil];
}

@end
