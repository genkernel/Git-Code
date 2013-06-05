//
//  DAModifiedHeader.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAModifiedHeader.h"

@implementation DAModifiedHeader

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

- (void)loadDelta:(GTDiffDelta *)delta {
	self.statsLabel.text = [NSString stringWithFormat:@"%d additions / %d deletions", delta.addedLinesCount, delta.deletedLinesCount];
}

@end
