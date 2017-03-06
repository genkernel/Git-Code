//
//  UIView+Helper.h
//  Interior Fusion
//
//  Created by kernel on 9/10/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Helper)
// General.
- (void)removeAllSubviews;
- (UIColor *)colorAtPoint:(CGPoint)point;
- (UIImage *)screeshotWithCurrentContext;
- (void)applyShadowOfRadius:(CGFloat)width withColor:(UIColor *)color;

- (UIView *)subviewOfType:(Class)cls;
- (UIView *)subviewOfType:(Class)cls traversingAllSubviewsTree:(BOOL)traverse;

- (void)pinToSuperviewEdgesNative;

#ifdef DEBUG
- (void)colorizeBorderWithColor:(UIColor *)color;
#endif

@property (nonatomic) CGFloat width, height;
@end
