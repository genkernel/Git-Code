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
	
	UIImage *img = [UIImage resizableImageFromColor:UIColor.acceptingGreenColor];
	[self setBackgroundImage:img forState:UIControlStateNormal];
	
	[self applyGeneralStyle];
}

- (void)applyBlueStyle {
	self.backgroundColor = UIColor.acceptingBlueColor;
	
	UIImage *img = [UIImage resizableImageFromColor:UIColor.acceptingBlueColor];
	[self setBackgroundImage:img forState:UIControlStateNormal];
	
	[self applyGeneralStyle];
}

- (void)applyRedStyle {
	self.backgroundColor = UIColor.cancelingRedColor;
	
	UIImage *img = [UIImage resizableImageFromColor:UIColor.cancelingRedColor];
	[self setBackgroundImage:img forState:UIControlStateNormal];
	
	[self applyGeneralStyle];
}

- (void)applyGeneralStyle {
	self.layer.cornerRadius = 2.;
	
	self.clipsToBounds = YES;
	
	[self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
	[self setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
	
	UIImage *img = [UIImage resizableImageFromColor:UIColor.inactiveGrayColor];
	[self setBackgroundImage:img forState:UIControlStateDisabled];
}

@end
