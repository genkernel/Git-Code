//
//  DAAppDelegate.m
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAppDelegate.h"

#import "DAFrameCtrl+Internal.h"
#import "DALoginCtrl.h"

#import "DAGitServer+Creation.h"

@implementation DAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//	[self genRoundedImage:application];
	
//#ifdef GIT_SSH
//	[Logger info:@"abc"];
//#endif
	
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	DAFrameCtrl *frameCtrl = (DAFrameCtrl *)application.rootCtrl;
	
	if (frameCtrl.overlayCtrl) {
		[frameCtrl dismissOverlayCtrl:frameCtrl.overlayCtrl animated:NO];
	}
	
	if (frameCtrl.menuCtrl) {
		[frameCtrl dismissMenuCtrl:frameCtrl.menuCtrl animated:NO];
	}
	
	UINavigationController *navCtrl = (UINavigationController *)frameCtrl.mainCtrl;
	
	if (![navCtrl.topViewController isKindOfClass:DALoginCtrl.class]) {
		[navCtrl popToRootViewControllerAnimated:NO];
	}
	
	return [self processRepoUrl:url loginCtrl:navCtrl.viewControllers.firstObject];
}

- (NSString *)repoPathFromURL:(NSURL *)inputUrl {
	NSArray *componets = inputUrl.pathComponents;
	
	if (componets.count != 3 || ![@"/" isEqualToString:componets.firstObject]) {
		return nil;
	}
	if (![componets[1] length] || ![componets[2] length]) {
		return nil;
	}
	
	return [NSString stringWithFormat:@"%@/%@", componets[1], componets[2]];
}

- (BOOL)processRepoUrl:(NSURL *)inputUrl loginCtrl:(DALoginCtrl *)loginCtrl {
	NSString *repoPath = [self repoPathFromURL:inputUrl];
	
	if (!repoPath) {
		NSString *message = NSLocalizedString(@"Failed to create new repository.\nInvalid URL specified: %@\n\nRequired url format: git://server-name.domain/<username>/<repository>", nil);
		
		message = [NSString stringWithFormat:message, inputUrl];
		
		[loginCtrl showErrorMessage:message];
		
		return NO;
	}
	
	NSString *serverUrl = inputUrl.host;
	NSString *serverName = serverUrl.stringByDeletingPathExtension.capitalizedString;
	
	DAGitServer *server = [DAServerManager.manager findServerByName:serverName];
	
	if (!server) {
		NSDictionary *serverInfo = @{ServerName: serverName,
									 ServerGitBaseUrl: serverUrl,
									 SaveDirectory: serverName,
									 LogoIcon: @"Git-Icon.png",
									 TransferProtocol: @"git://",
									 SupportedProtocols: @[@"https://", @"git://", @"http://"],
									 RecentRepoPath: repoPath,
									 RecentRepos: @{}};
		
		server = [loginCtrl createNewServerWithDictionary:serverInfo];
	}
	
	[loginCtrl scrollToServer:server animated:NO];
	
	[loginCtrl exploreRepoWithPath:repoPath];
	
	return YES;
}

#pragma mark Helper methods

- (void)createSharedCacheForApplication:(UIApplication *)app {
	NSString *cacheDirectoryName = @"NetworkCache";
	
	const NSUInteger memotyCapacity = 4 * 1024 * 1024;
	const NSUInteger diskCapacity = 16 * 1024 * 1024;
	NSURLCache *cache = [NSURLCache.alloc initWithMemoryCapacity:memotyCapacity diskCapacity:diskCapacity diskPath:cacheDirectoryName];
	
	NSURLCache.sharedURLCache = cache;
}

- (void)genRoundedImage:(UIApplication *)app {
	UIView *v = [UIView.alloc initWithFrame:CGRectMake(0, 0, 88, 256)];
	v.layer.masksToBounds = YES;
	v.layer.cornerRadius = 7;
	
	v.backgroundColor = UIColor.acceptingGreenColor;
	
	UIImage *img = v.screeshotWithCurrentContext;
	
	NSData *data = UIImagePNGRepresentation(img);
	[data writeToFile:[app.documentsPath concat:@"/123.png"] atomically:YES];
}

@end
