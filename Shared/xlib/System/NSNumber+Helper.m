//
//  NSNumber+Bits.m
//  Test
//
//  Created by kernel on 30/06/12.
//  Copyright (c) 2012 Test. All rights reserved.
//

#import "NSNumber+Helper.h"

@implementation NSNumber (Helper)

+ (u_int32_t)randomTo:(u_int32_t)count {
	return (u_int32_t)arc4random_uniform(count);
	
//	arc4random does not require an initial seed (with srand or srandom)
//	return arc4random() % count;
}

+ (double)randomDoubleBetweenZeroAndOne {
	srand48(time(0));
	return drand48();
}

- (void)hello {
	int leading = __builtin_clz(1);
	int trailing = __builtin_ctz(1);
	NSLog(@"L: %d. T: %d", leading, trailing);
}

- (NSNumber *)fromDegreesToRadians
{
	return @([self.class degreesToRadians:self.floatValue]);
}

- (NSNumber *)fromRadiansToDegrees
{
	return @([self.class radiansToDegrees:self.floatValue]);
}

+ (CGFloat)degreesToRadians:(CGFloat)degrees
{
	return degrees * M_PI / 180;
}

+ (CGFloat)radiansToDegrees:(CGFloat)radians
{
	return radians * 180 / M_PI;
};

@end
