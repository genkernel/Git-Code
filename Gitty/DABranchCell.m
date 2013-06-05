//
//  DABranchCell.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchCell.h"

@implementation DABranchCell

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
        [self setupContentView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView {
	NSArray *views = [NSBundle.mainBundle loadNibNamed:self.className owner:self options:nil];
	
	UIView *view = views[0];
	view.frame = self.contentView.bounds;
	view.autoresizingMask = UIView.AutoresizingAll;
	
	[self.contentView addSubview:view];
}

@end
