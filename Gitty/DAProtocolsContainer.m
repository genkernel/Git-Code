//
//  DAProtocolsContainer.m
//  Gitty
//
//  Created by kernel on 2/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAProtocolsContainer.h"

static const CGFloat MarginBetweenButtons = 6.;

@implementation DAProtocolsContainer

- (CGSize)intrinsicContentSize {
	CGFloat width = .0, height = .0;
	
	for (UIView *button in self.subviews) {
		width += button.intrinsicContentSize.width;
		height = MAX(height, button.intrinsicContentSize.height);
	}
	
	if (self.subviews.count > 1) {
		width += MarginBetweenButtons * self.subviews.count;
	}
	
	return CGSizeMake(width, height);
	
//	[Logger info:@"0x%X (subviews: %d) intrinsicSize: %@", self, self.subviews.count, NSStringFromCGSize(s)];
}

- (void)removeAllButtonsAndResetLayout {
	[self removeAllSubviews];
	
	[self removeConstraints:self.constraints];
	
	UIView *view = self;
	NSDictionary *views = NSDictionaryOfVariableBindings(view);
	
	//(>=50)
	NSArray *width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[view]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views];
	[self.superview addConstraints:width];
	
	//(20)
	NSArray *height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]" options:NSLayoutFormatAlignAllTop metrics:nil views:views];
	[self.superview addConstraints:height];
}

// Aligns buttons in line followed one-by-one.
- (void)insertAndLayoutNextProtocolButton:(UIButton *)button {
	CGFloat leftMargin = .0;
	
	UIButton *previousButton = nil;
	if (self.subviews.count) {
		leftMargin = MarginBetweenButtons;
		previousButton = self.subviews.lastObject;
	}
	
	[self addSubview:button];
	
	NSArray *width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(>=40)]" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(button)];
	[button addConstraints:width];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:NSLayoutAttributeRight multiplier:1. constant:leftMargin];
	[self addConstraint:constraint];
}

@end
