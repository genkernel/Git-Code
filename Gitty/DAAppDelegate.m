//
//  DAAppDelegate.m
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAppDelegate.h"

@implementation DAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if (!IS_IPHONE_5) {
		[ViewCtrl setDevicePostfix:@"-3.5inches"];
	}
	
	[self createSharedCacheForApplication:application];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[DAGitManager.manager scanAllDeletableLocalReposAndDelete];
	});
	
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[DASshCredentials.manager scanNewKeyArchives];
	});
}

#pragma mark Helper methods

- (void)createSharedCacheForApplication:(UIApplication *)app {
	NSString *cacheDirectoryName = @"NetworkCache";
	
	const NSUInteger memotyCapacity = 4 * 1024 * 1024;
	const NSUInteger diskCapacity = 16 * 1024 * 1024;
	NSURLCache *cache = [NSURLCache.alloc initWithMemoryCapacity:memotyCapacity diskCapacity:diskCapacity diskPath:cacheDirectoryName];
	
	NSURLCache.sharedURLCache = cache;
}

@end
