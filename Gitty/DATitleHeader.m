//
//  DATitleHeader.m
//  Gitty
//
//  Created by kernel on 17/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DATitleHeader.h"

@implementation DATitleHeader

- (id)init {
	self = [super init];
	if (self) {
		NSArray *views = [[NSBundle mainBundle] loadNibNamed:self.className owner:self options:nil];
		UIView *view = views.lastObject;
		
		self.bounds = view.bounds;
		[self addSubview:view];
	}
	return self;
}

@end
