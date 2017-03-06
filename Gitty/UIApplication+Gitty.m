//
//  UIApplication+Gitty.m
//  Git Code
//
//  Created by Anthony on 3/5/17.
//  Copyright © 2017 ReImpl. All rights reserved.
//

#import "UIApplication+Gitty.h"

@implementation UIApplication (Gitty)

- (NSFileManager *)fs {
	return NSFileManager.defaultManager;
}

- (UIViewController *)rootCtrl {
	return UIApplication.sharedApplication.keyWindow.rootViewController;
}

- (NSString *)cachesPath {
	return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

- (NSString *)documentsPath {
	return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

@end
