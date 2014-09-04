//
//  WMBlockedCountryWindow.m
//  Sidus
//
//  Created by Altukhov Anton on 9/3/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "WMGeoBlockerWindow.h"

#import "DAAppDelegate.h"

@implementation WMGeoBlockerWindow

+ (void)checkCurrentCountry {
	NSDictionary *blockedCountry = [NSUserDefaults.standardUserDefaults dictionaryForKey:@"previouslyBlockedCountry"];
	
	if (blockedCountry) {
		[self blockUIForCountryWithInfo:blockedCountry];
		return;
	}
	
	[NSNotificationCenter.defaultCenter addObserverForName:RIGlobalAppSettingsReceived object:RIGlobalAppSettings.manager queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
		NSArray *blockedCodes = RIGlobalAppSettings.manager.blockedCountryCodes;
		
		if (!blockedCodes.count) {
			blockedCodes = @[@"RU"];
		}
		
		[self checkCurrentCountryAgainstBlockedCodes:blockedCodes];
	}];
	
	[RIGlobalAppSettings manager];
}

+ (void)checkCurrentCountryAgainstBlockedCodes:(NSArray *)blockedCodes {
	
	[NSNotificationCenter.defaultCenter addObserverForName:RIGeoManagerRecentCountryDidChange object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
		
		NSDictionary *country = RIGeoManager.manager.recentCountry;
		[self checkCurrentCountry:country againstBlockedCodes:blockedCodes];
	}];
	
	NSDictionary *country = RIGeoManager.manager.recentCountry;
	[self checkCurrentCountry:country againstBlockedCodes:blockedCodes];
}

+ (void)checkCurrentCountry:(NSDictionary *)country againstBlockedCodes:(NSArray *)blockedCodes {
	NSString *code = country[@"code"];
	
	if (![code isKindOfClass:NSString.class]) {
		return;
	}
	
	for (NSString *blockedCode in blockedCodes) {
		if (NSOrderedSame == [code caseInsensitiveCompare:blockedCode]) {
			[self blockUIForCountryWithInfo:country];
			
			return;
		}
	}
}

+ (void)blockUIForCountryWithInfo:(NSDictionary *)info {
	[NSUserDefaults.standardUserDefaults setObject:info forKey:@"previouslyBlockedCountry"];
	
	UINib *nib = [UINib nibWithNibName:self.className bundle:nil];
	
	WMGeoBlockerWindow *window = [nib instantiateWithOwner:nil options:nil].firstObject;
	
	window.infoLabel.text = [self blockingInfoTextWithCountryName:info[@"name"]];
	
	DAAppDelegate *app = (DAAppDelegate *)UIApplication.sharedApplication.delegate;
	app.window = window;
	
	[window makeKeyAndVisible];
}

+ (NSString *)blockingInfoTextWithCountryName:(NSString *)countryName {
	NSString *appName = UIApplication.sharedApplication.appDisplayName;
	
	return [NSString stringWithFormat:@"%@ service is currently not available in %@.", appName, countryName];
}

@end
