//
//  DAAuthorHeader.m
//  Gitty
//
//  Created by kernel on 12/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAuthorHeader.h"

@implementation DAAuthorHeader

- (id)init
{
    self = [super init];
    if (self) {
		NSArray *views = [NSBundle.mainBundle loadNibNamed:self.className owner:self options:nil];
		
		UIView *view = views[0];
		self.frame = view.bounds;
		
		[self addSubview:view];
		
		[self setupView];
    }
    return self;
}

- (void)setupView {
	[self.avatar applyAvatarStyle];
}

- (void)loadAuthor:(GTSignature *)author {
	self.nameLabel.text = author.name;
	[self.avatar setGravatarImageWithEmail:author.email];
}

@end
