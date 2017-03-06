//
//  PageControl.m
//  Gitty
//
//  Created by kernel on 2/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "PageControl.h"

@implementation PageControl

- (void)setCurrentPage:(NSInteger)currentPage {
	[super setCurrentPage:currentPage];
	
	[self updateDots];
}

#pragma mark Internal

-(void)updateDots {
	NSUInteger index = 0;
	for (UIImageView *dot in self.subviews) {
		if (![dot isKindOfClass:UIImageView.class]) {
			continue;
		}
		
		UIImage *img = nil;
		
		if (index == self.currentPage) {
			img = [self.delegate activeImageForIndex:index];
		} else {
			img = [self.delegate inactiveImageForIndex:index];
		}
		
		if (img) {
			dot.image = img;
		}
		
		index++;
    }
}

@end
