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
	NSURLCache *cache = NSURLCache.sharedURLCache;
	cache.memoryCapacity = 10 * 1024 * 1024;
	cache.diskCapacity = 128 * 1024 * 1024;
	
    return YES;
}

@end
