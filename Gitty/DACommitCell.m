//
//  DACommitCell.m
//  Gitty
//
//  Created by kernel on 4/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DACommitCell.h"

static CGFloat InitialCellHeight = .0;
static CGFloat CommitMessageMaxHeight = 120.;

@implementation DACommitCell {
	CGFloat commitMessageSingleLineHeight;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	InitialCellHeight = self.height;
	commitMessageSingleLineHeight = self.commitLabel.font.lineHeight;
	
	[self.avatar applyAvatarStyle];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self.avatar cancelImageRequestOperation];
}

- (CGFloat)heightForCommit:(GTCommit *)commit {
	CGSize s = CGSizeMake(self.commitLabel.width, CommitMessageMaxHeight);
	s = [commit.message sizeWithFont:self.commitLabel.font constrainedToSize:s lineBreakMode:self.commitLabel.lineBreakMode];
	
	CGFloat height = InitialCellHeight;
	
	BOOL isMultiline = s.height > commitMessageSingleLineHeight;
	if (isMultiline) {
		height += s.height - commitMessageSingleLineHeight;
	}
	
	return height;
}

- (void)loadCommit:(GTCommit *)commit {
	[super loadCommit:commit];
	
	[self.avatar setGravatarImageWithEmail:commit.author.email];
	self.authorLabel.text = [NSString stringWithFormat:@"%@", commit.author.name];
}

@end
