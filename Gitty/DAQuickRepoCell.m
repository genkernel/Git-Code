//
//  DAQuickRepoCell.m
//  Gitty
//
//  Created by kernel on 4/10/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAQuickRepoCell.h"

@implementation DAQuickRepoCell

- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self setActive:NO];
}

- (void)setActive:(BOOL)active {
	NSString *name = active ? @"Git-Icon_red.png" : @"Git-Icon.png";
	self.logo.image = [UIImage imageNamed:name];
	
	self.nameLabel.textColor = active ? UIColor.acceptingBlueColor : UIColor.blackColor;
}

- (void)loadRepo:(NSDictionary *)repo active:(BOOL)active {
	self.nameLabel.text = repo.relativePath;
	
	[self setActive:active];
}

@end
