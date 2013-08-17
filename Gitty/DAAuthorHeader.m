//
//  DAAuthorHeader.m
//  Gitty
//
//  Created by kernel on 12/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAuthorHeader.h"

@implementation DAAuthorHeader

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self.avatar applyAvatarStyle];
}

- (void)loadAuthor:(GTSignature *)author {
	self.nameLabel.text = author.name;
	[self.avatar setGravatarImageWithEmail:author.email];
}

@end
