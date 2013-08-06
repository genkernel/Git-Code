//
//  DACommitMessageCell.m
//  Gitty
//
//  Created by kernel on 5/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DACommitMessageCell.h"

static CGFloat InitialCellHeight = .0;
static CGFloat CommitMessageMaxHeight = 120.;

@interface DACommitMessageCell ()
@property (strong, nonatomic, readonly) NSDateFormatter *dateFormatter;
@end

@implementation DACommitMessageCell {
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
	[self generateInfoStringForCommit:commit];
	
	self.commitLabel.text = [NSString stringWithFormat:@"%@", commit.message];
}

- (void)setShowsTopCellSeparator:(BOOL)shows {
	self.separatorLine.hidden = !shows;
}

- (void)generateInfoStringForCommit:(GTCommit *)commit {
	NSArray *strings = nil;
	{
		NSString *sha = [NSString stringWithFormat:@"#%@", commit.shortSHA];
		
		self.dateFormatter.timeZone = commit.commitTimeZone;
		NSString *timestamp = [self.dateFormatter stringFromDate:commit.commitDate];
		
		strings = @[sha, [NSString stringWithFormat:@"on %@", timestamp]];
	}
	
	NSArray *attributes = nil;
	{
		UIFont *font = self.infoLabel.font;
		
		NSDictionary *shaAttr = [NSAttributedString attributesWithTextColor:UIColor.commitNameTintColor font:font alignment:NSTextAlignmentNatural];
		NSDictionary *dateAttr = [NSAttributedString attributesWithTextColor:UIColor.lightGrayColor font:font alignment:NSTextAlignmentNatural];
		
		attributes = @[shaAttr, dateAttr];
	}
	
	self.infoLabel.attributedText = [NSAttributedString stringByJoiningSimpleStrings:strings applyingAttributes:attributes joinString:@" "];
}

- (void)setShowsDayName:(BOOL)showsDayName {
	self.dateFormatter.dateFormat = showsDayName ? @"E, h:mm a" : @"h:mm a";
}

#pragma mark Properties

- (NSDateFormatter *)dateFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.dateFormat = @"h:mm a";
	});
	return formatter;
}

@end
