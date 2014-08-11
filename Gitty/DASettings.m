//
//  DASettings.m
//  Gitty
//
//  Created by kernel on 24/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DASettings.h"

@implementation DASettings

+ (instancetype)currentUserSettings {
	static id instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	
	return instance;
}

- (int)doAction:(NSString *)name {
	int counter = [self countForAction:name];
	
	counter++;
	
	[NSUserDefaults.standardUserDefaults setInteger:counter forKey:name];
	
	return counter;
}

- (int)countForAction:(NSString *)name {
	return (int)[NSUserDefaults.standardUserDefaults integerForKey:name];
}

#pragma mark Properties

- (BOOL)didPresentSwipeToServerHint {
	return [NSUserDefaults.standardUserDefaults boolForKey:@"didPresentSwipeToServerHint"];
}

- (void)setDidPresentSwipeToServerHint:(BOOL)shouldHandle {
	[NSUserDefaults.standardUserDefaults setBool:shouldHandle forKey:@"didPresentSwipeToServerHint"];
	[NSUserDefaults.standardUserDefaults synchronize];
}

- (BOOL)didPresentRevealStatsHint {
	return [NSUserDefaults.standardUserDefaults boolForKey:@"didPresentRevealStatsHint"];
}

- (void)setDidPresentRevealStatsHint:(BOOL)shouldHandle {
	[NSUserDefaults.standardUserDefaults setBool:shouldHandle forKey:@"didPresentRevealStatsHint"];
	[NSUserDefaults.standardUserDefaults synchronize];
}

@end
