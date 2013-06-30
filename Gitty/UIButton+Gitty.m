//
//  UIButton+Gitty.m
//  Gitty
//
//  Created by kernel on 16/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "UIButton+Gitty.h"

@implementation UIButton (Gitty)

- (void)applyGreenStyle {
	self.backgroundColor = UIColor.acceptingGreenColor;
	
	UIImage *img = [UIImage imageNamed:@"btn-green.png"];
	[self setBackgroundImage:img forState:UIControlStateNormal];
	
	[self applyGeneralStyle];
}

- (void)applyBlueStyle {
	self.backgroundColor = UIColor.acceptingBlueColor;
	
	UIImage *img = [UIImage imageNamed:@"btn-blue.png"];
	[self setBackgroundImage:img forState:UIControlStateNormal];
	
	[self applyGeneralStyle];
}

- (void)applyRedStyle {
	self.backgroundColor = UIColor.cancelingRedColor;
	
	UIImage *img = [UIImage imageNamed:@"btn-red.png"];
	[self setBackgroundImage:img forState:UIControlStateNormal];
	
	[self applyGeneralStyle];
}

- (void)applyGeneralStyle {
	self.layer.cornerRadius = 5.;
	
	[self applyShadowOfRadius:2. withColor:UIColor.blackColor];
	
	[self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
	[self setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
	
	UIImage *img = [UIImage imageNamed:@"btn-gray.png"];
	[self setBackgroundImage:img forState:UIControlStateDisabled];
}

@end
