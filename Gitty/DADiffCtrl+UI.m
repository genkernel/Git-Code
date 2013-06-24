//
//  DADiffCtrl+UI.m
//  Gitty
//
//  Created by kernel on 24/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADiffCtrl+UI.h"

@implementation DADiffCtrl (UI)

- (void)cacheView:(UIView *)view withIdentifier:(NSString *)identifier {
	NSMutableSet *views = _cachedViews[identifier];
	if (!views) {	
		views = NSMutableSet.new;
		_cachedViews[identifier] = views;
	}
	
	[views addObject:view];
}

- (UIView *)cachedViewWithIdentifier:(NSString *)identifier {
	NSMutableSet *views = _cachedViews[identifier];
	if (!views) {
		return nil;
	}
	
	UIView *v = views.anyObject;
	if (v) {
		[views removeObject:v];
	}
	return v;
}

@end
