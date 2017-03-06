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
	NSMutableArray *_list;
}
@synthesize list = _list;
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

		_list = [NSMutableArray arrayWithCapacity:servers.count];
		
		for (NSDictionary *dict in servers) {
			[_list addObject:[DAGitServer serverWithDictionary:dict]];
		}
	}
	return self;
}

- (void)addNewServer:(DAGitServer *)server {
	[_list addObject:server];
	
	[self save];
}

- (void)removeExistingServer:(DAGitServer *)server {
	[_list removeObject:server];
	
	[self save];
}

- (void)save {
	NSMutableArray *saveArr = [NSMutableArray arrayWithCapacity:self.list.count];
	
	for (DAGitServer *saveServer in self.list) {
		[saveArr addObject:saveServer.saveDict];
	}
	
	[saveArr writeToFile:self.storePath atomically:YES];
}

- (DAGitServer *)findServerByName:(NSString *)name {
	for (DAGitServer *server in self.list) {
		if (NSOrderedSame == [name caseInsensitiveCompare:server.name]) {
			return server;
		}
	}
	
	return nil;
}

#pragma mark Properties

- (NSString *)storePath {
	NSString *hiddenFileName = [@"." concat:StoreFilename];
	
	return [UIApplication.sharedApplication.documentsPath stringByAppendingPathComponent:hiddenFileName];
}

#pragma mark Internals

- (void)copyInitialStoreFileIfNeeded {
	NSFileManager *fs = UIApplication.sharedApplication.fs;
	
	if ([fs isFileExistentAtPath:self.storePath]) {
		return;
	}
	
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:StoreFilename.stringByDeletingPathExtension ofType:StoreFilename.pathExtension];
	[fs copyItemAtPath:bundlePath toPath:self.storePath error:nil];
}

@end
