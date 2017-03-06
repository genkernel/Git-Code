//
//  UISearchBar+Helper.m
//  WiFi Music
//
//  Created by Shawn Altukhov on 11/06/2014.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "UISearchBar+Helper.h"

@implementation UISearchBar (Helper)
@dynamic textField;

- (UITextField *)textField {
	return (UITextField *)[self subviewOfType:UITextField.class traversingAllSubviewsTree:YES];
}

- (void)enableAllControlButtons {
	for (UIView *v in self.subviews) {
		if ([v isKindOfClass:UIControl.class]) {
			((UIControl *)v).enabled = YES;
		}
	}
}

#pragma mark Forwarding to Original DataSource - iOS7

/**
 * iOS7
 *
- (id)forwardingTargetForSelector:(SEL)selector {
	if ([self.textField respondsToSelector:selector]) {
		return self.textField;
	}
	
	return nil;
}*/

@end
