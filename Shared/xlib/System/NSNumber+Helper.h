//
//  NSNumber+Bits.h
//  Test
//
//  Created by kernel on 30/06/12.
//  Copyright (c) 2012 Test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSNumber (Helper)
+ (u_int32_t)randomTo:(u_int32_t)count;
+ (double)randomDoubleBetweenZeroAndOne;

@property (nonatomic, retain, readonly) NSNumber *fromDegreesToRadians;
@property (nonatomic, retain, readonly) NSNumber *fromRadiansToDegrees;

+ (CGFloat)degreesToRadians:(CGFloat)degrees;
+ (CGFloat)radiansToDegrees:(CGFloat)radians;
@end
