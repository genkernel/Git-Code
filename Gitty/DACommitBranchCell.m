//
//  DACommitBranchCell.m
//  Gitty
//
//  Created by kernel on 12/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DACommitBranchCell.h"

static CGFloat InitialCellHeight = .0;
static CGFloat CommitMessageMaxHeight = 120.;

@interface DACommitBranchCell ()
@property (strong, nonatomic, readonly) NSDateFormatter *dateFormatter;
@end

@implementation DACommitBranchCell {
	CGFloat commitMessageSingleLineHeight;
}
@dynamic dateFormatter;

- (void)awakeFromNib {
	[super awakeFromNib];
	
	InitialCellHeight = self.height;
	commitMessageSingleLineHeight = self.commitLabel.font.lineHeight;
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
	self.branchLabel.text = @"";
	self.shortShaLabel.text = [NSString stringWithFormat:@"#%@", commit.shortSha];
	
	self.dateFormatter.timeZone = commit.commitTimeZone;
	self.dateLabel.text = [self.dateFormatter stringFromDate:commit.commitDate];
	
	self.commitLabel.text = [NSString stringWithFormat:@"%@", commit.message];
}

- (void)loadBranch:(GTBranch *)branch {
	self.branchLabel.text = branch.name.lastPathComponent;
}

- (void)setShowsTopCellSeparator:(BOOL)shows {
	self.separatorLine.hidden = !shows;
}

#pragma mark Properties

- (NSDateFormatter *)dateFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.dateFormat = @"E, h:mm a";
	});
	return formatter;
}

@end
