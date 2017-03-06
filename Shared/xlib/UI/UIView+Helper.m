//
//  UIView+Helper.m
//  Interior Fusion
//
//  Created by kernel on 9/10/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "UIView+Helper.h"

#import "UI-Constants.h"
#import "UIDevice+Helper.h"

@implementation UIView (Helper)

- (void)removeAllSubviews {
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
}

- (UIColor *)colorAtPoint:(CGPoint)point {
	unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, /*kCGImageAlphaPremultipliedLast*/kCGBitmapAlphaInfoMask);
	
    CGContextTranslateCTM(context, -point.x, -point.y);
	
    [self.layer renderInContext:context];
	
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    return color;
}

- (UIImage *)screeshotWithCurrentContext {
	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (UIDevice.currentDevice.isIos7FamilyOrGreater) {
		[self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
	} else {
		[self.layer renderInContext:context];
	}

	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return img;
}

- (void)applyShadowOfRadius:(CGFloat)radius withColor:(UIColor *)color {
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOpacity = 0.6f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = radius;
    self.layer.masksToBounds = NO;
	
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.shadowPath = path.CGPath;
}

- (UIView *)subviewOfType:(Class)cls {
	return [self subviewOfType:cls traversingAllSubviewsTree:NO];
}

- (UIView *)subviewOfType:(Class)cls traversingAllSubviewsTree:(BOOL)traverse {
	for (UIView *v in self.subviews) {
		if ([v isKindOfClass:cls]) {
			return v;
		}
		
		if (traverse) {
			UIView *innerView = [v subviewOfType:cls traversingAllSubviewsTree:traverse];
			
			if (innerView) {
				return innerView;
			}
		}
	}
	
	return nil;
}

#ifdef DEBUG
- (void)colorizeBorderWithColor:(UIColor *)color {
	self.layer.borderColor = color.CGColor;
	self.layer.borderWidth = 2.;
}
#endif

#pragma mark Autolayout

- (void)pinToSuperviewEdgesNative {
	self.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1. constant:.0];
	[self.superview addConstraint:top];
	
	NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1. constant:.0];
	[self.superview addConstraint:left];
	
	NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1. constant:.0];
	[self.superview addConstraint:bottom];
	
	NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1. constant:.0];
	[self.superview addConstraint:right];
}

- (CGFloat)width {
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (CGFloat)height {
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

@end
