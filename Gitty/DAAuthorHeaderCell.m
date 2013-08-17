//
//  DAAuthorHeader.m
//  Gitty
//
//  Created by kernel on 12/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAuthorHeaderCell.h"

@implementation DAAuthorHeaderCell
@dynamic collapsed;

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self.avatar applyAvatarStyle];
}

- (void)loadAuthor:(GTSignature *)author {
	self.nameLabel.text = author.name;
	[self.avatar setGravatarImageWithEmail:author.email];
}

#pragma mark Properties

- (BOOL)collapsed {
	return self.toggleButton.selected;
}

- (void)setCollapsed:(BOOL)collapsed {
	self.toggleButton.selected = collapsed;
}

@end
