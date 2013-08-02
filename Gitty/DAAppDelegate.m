//
//  DAAppDelegate.m
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAppDelegate.h"

@implementation DAAppDelegate

- (void)genRoundedImage:(UIApplication *)app {
	UIView *v = [UIView.alloc initWithFrame:CGRectMake(0, 0, 88, 256)];
	v.layer.masksToBounds = YES;
	v.layer.cornerRadius = 7;
	
	v.backgroundColor = UIColor.acceptingGreenColor;
	
	UIImage *img = v.screeshotWithCurrentContext;
	
	NSData *data = UIImagePNGRepresentation(img);
	[data writeToFile:[app.documentsPath concat:@"/123.png"] atomically:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//	[self genRoundedImage:application];
	
	[DAFlurry.analytics start];
	
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
