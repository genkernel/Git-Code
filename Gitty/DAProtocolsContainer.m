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
	
//	[LLog info:@"0x%X (subviews: %d) intrinsicSize: %@", self, self.subviews.count, NSStringFromCGSize(s)];
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
	
	UIView *previousButton = nil;
	NSLayoutAttribute attribute = NSLayoutAttributeLeft;
	
	if (self.subviews.count) {
		leftMargin = MarginBetweenButtons;
		previousButton = self.subviews.lastObject;
		attribute = NSLayoutAttributeRight;
	} else {
		previousButton = self;
		attribute = NSLayoutAttributeLeft;
	}
	
	[self addSubview:button];
	
	NSArray *width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(>=40)]" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(button)];
	[button addConstraints:width];
	
	
	NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1. constant:0];
	[self addConstraint:top];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:attribute multiplier:1. constant:leftMargin];
	[self addConstraint:constraint];
}

@end
