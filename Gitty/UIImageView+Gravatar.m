//
//  UIImageView+Gravatar.m
//  Gitty
//
//  Created by kernel on 24/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "UIImageView+Gravatar.h"
#import "DAGravatar.h"

@implementation UIImageView (Gravatar)

- (void)setGravatarImageWithEmail:(NSString *)email {
	if (!email) {
		[Logger error:@"nil author's email specified. %s", __PRETTY_FUNCTION__];
		return;
	}
	NSURL *url = [DAGravatar.manager getUrlForEmail:email];
	[self setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile.png"]];
}

- (void)applyAvatarStyle {
	self.layer.cornerRadius = 4.;
	self.layer.masksToBounds = YES;
}

@end
