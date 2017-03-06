//
//  NSArray+AAV.m
//  CeleBro
//
//  Created by kernel on 11/11/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import "NSArray+AAV.h"

@implementation NSArray (AAV)

- (id)anyObject {
	if (0 == self.count) {
		return nil;
	}
	u_int32_t idx = [NSNumber randomTo:(u_int32_t)self.count];
	if (idx >= self.count) {
		idx -= 1;
	}
	return self[idx];
}

@end
