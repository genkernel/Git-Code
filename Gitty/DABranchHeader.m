//
//  DABranchHeader.m
//  Gitty
//
//  Created by kernel on 13/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchHeader.h"

@implementation DABranchHeader

- (id)init
{
    self = [super init];
    if (self) {
		NSArray *views = [NSBundle.mainBundle loadNibNamed:self.className owner:self options:nil];
		
		UIView *view = views[0];
		self.frame = view.bounds;
		
		[self addSubview:view];
    }
    return self;
}

@end
