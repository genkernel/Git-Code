//
//  UIImage+Utils.h
//  MagicImageEraser
//
//  Created by kernel on 23/12/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)
+ (instancetype)resizableImageFromColor:(UIColor *)color;
+ (instancetype)imageFromColor:(UIColor *)color ofSize:(CGSize)size;
@end
