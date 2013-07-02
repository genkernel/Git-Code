//
//  DAProtocolsContainer.m
//  Gitty
//
//  Created by kernel on 2/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAProtocolsContainer.h"

@implementation DAProtocolsContainer

- (CGSize)intrinsicContentSize {
	UIView *lastButton = self.subviews.lastObject;
	
	CGSize s = lastButton.intrinsicContentSize;
	return CGSizeMake(lastButton.x + s.width, s.height);
	
//	[Logger info:@"0x%X (subviews: %d) intrinsicSize: %@", self, self.subviews.count, NSStringFromCGSize(s)];
}

@end
