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
	NSURL *url =  [DAGravatar.manager getUrlForEmail:email];
	[self setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile.png"]];
}

@end
