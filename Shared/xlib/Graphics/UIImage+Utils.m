//
//  UIImage+Utils.m
//  MagicImageEraser
//
//  Created by kernel on 23/12/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

+ (instancetype)resizableImageFromColor:(UIColor *)color {
	UIImage *img = [self imageFromColor:color ofSize:CGSizeMake(1, 1)];
	return [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

+ (instancetype)imageFromColor:(UIColor *)color ofSize:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}

@end
