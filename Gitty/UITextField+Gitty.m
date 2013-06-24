//
//  UITextField+Gitty.m
//  Gitty
//
//  Created by kernel on 24/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "UITextField+Gitty.h"

@implementation UITextField (Gitty)

- (void)applyThinStyle {
	self.layer.borderWidth = 1.;
	self.layer.cornerRadius = 5.;
	self.layer.masksToBounds = YES;
	self.layer.borderColor = UIColor.lightGrayColor.CGColor;
}

@end
