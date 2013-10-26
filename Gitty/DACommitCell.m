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
	self.commitLabel.text = commit.message;
	
	CGRect r = CGRectMake(0, 0, self.commitLabel.width, CommitMessageMaxHeight);
	r = [self.commitLabel textRectForBounds:r limitedToNumberOfLines:6];
	
	CGSize s = r.size;
	CGFloat height = InitialCellHeight;
	
	BOOL isMultiline = s.height > commitMessageSingleLineHeight;
	if (isMultiline) {
		height += s.height - commitMessageSingleLineHeight;
	}
	
	return height;
}

- (void)loadCommit:(GTCommit *)commit author:(GTSignature *)author {
	[super loadCommit:commit author:author];
	
	[self.avatar setGravatarImageWithEmail:author.email];
	self.authorLabel.text = [NSString stringWithFormat:@"%@", author.name];
}

@end
