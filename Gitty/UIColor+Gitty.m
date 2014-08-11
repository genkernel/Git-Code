//
//  UIColor+Gitty.m
//  Gitty
//
//  Created by kernel on 9/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "UIColor+Gitty.h"

@implementation UIColor (Gitty)

+ (UIColor *)graphAdditionColor {
	return [UIColor colorWithRed:51./255. green:204./255. blue:102./255. alpha:1.];
}

+ (UIColor *)graphDeletionColor {
	return [UIColor colorWithRed:1. green:51./255. blue:51./255. alpha:1.];
}

+ (UIColor *)graphContextColor {
	return [UIColor colorWithRed:155./255. green:155./255. blue:155./255. alpha:1.];
}

+ (UIColor *)codeAdditionColor {
	return [UIColor colorWithRed:223./255. green:1. blue:218./255. alpha:1.];
}

+ (UIColor *)codeDeletionColor {
	return [UIColor colorWithRed:1. green:221./255. blue:221./255. alpha:1.];
}

+ (UIColor *)codeContextColor {
	return [UIColor colorWithRed:230./255. green:230./255. blue:230./255. alpha:1.];
}

+ (UIColor *)acceptingGreenColor {
	return RGB(75, 217, 99);
}

+ (UIColor *)acceptingBlueColor {
	return RGB(51, 153, 255);
}

+ (UIColor *)inactiveGrayColor {
	return [UIColor colorWithRed:145./255. green:164./255. blue:187./255. alpha:1.];
}

+ (UIColor *)cancelingRedColor {
	return RGB(255, 51, 51);
}

+ (UIColor *)branchNameTintColor {
	return [UIColor colorWithRed:1. green:51./255. blue:51./255. alpha:1.];
}

+ (UIColor *)authorNameTintColor {
	return [UIColor colorWithRed:75./255. green:217./255. blue:99./255. alpha:1.];
}

+ (UIColor *)commitNameTintColor {
	return [UIColor colorWithRed:51./255. green:153./255. blue:1. alpha:1.];
}

+ (UIColor *)bluringColor {
	static UIColor *color = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		color = [UIColor colorWithWhite:.9 alpha:1];
//		color = [UIColor colorWithRed:.66 green:.68 blue:.70 alpha:1];
	});
	
	return color;
}

+ (UIColor *)barBluringColor {
	static UIColor *color = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		color = [UIColor darkGrayColor];
	});
	
	return color;
}

@end
