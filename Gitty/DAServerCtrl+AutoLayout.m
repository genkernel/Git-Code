//
//  DAServerCtrl+AutoLayout.m
//  Gitty
//
//  Created by kernel on 2/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAServerCtrl+AutoLayout.h"

@implementation DAServerCtrl (AutoLayout)

- (void)layoutProtocolsContainer {
	UIView *protocols = self.protocolsContainer;
	NSDictionary *views = NSDictionaryOfVariableBindings(protocols);
	
	//(>=50)
	NSArray *width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[protocols]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views];
	[self.protocolsContainer addConstraints:width];
	
	//(20)
	NSArray *height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[protocols]" options:NSLayoutFormatAlignAllTop metrics:nil views:views];
	[self.protocolsContainer addConstraints:height];
}

// Aligns buttons in line followed one-by-one.
- (void)insertAndLayoutNextProtocolButton:(UIButton *)button {
	CGFloat leftMargin = .0;
	
	UIButton *previousButton = nil;
	if (self.protocolsContainer.subviews.count) {
		leftMargin = 6.;
		previousButton = self.protocolsContainer.subviews.lastObject;
	}
	
	[self.protocolsContainer addSubview:button];
	
	NSArray *width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(>=40)]" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(button)];
	[button addConstraints:width];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:NSLayoutAttributeRight multiplier:1. constant:leftMargin];
	[self.protocolsContainer addConstraint:constraint];
}

@end
