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
@property (weak, nonatomic, readonly) GTCommit *commit;
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
	self.commitLabel.text = commit.message;
	
	CGRect r = CGRectMake(0, 0, self.width, CommitMessageMaxHeight);
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
	_commit = commit;
	
	self.commitLabel.text = [NSString stringWithFormat:@"%@", commit.message];
}

- (void)loadBranch:(GTBranch *)branch {
	[self generateInfoStringForCommit:self.commit inBranch:branch];
}

- (void)setShowsTopCellSeparator:(BOOL)shows {
	self.separatorLine.hidden = !shows;
}

- (void)generateInfoStringForCommit:(GTCommit *)commit inBranch:(GTBranch *)branch {
	
	NSArray *strings = nil;
	{
		NSString *sha = [NSString stringWithFormat:@"#%@", commit.shortSHA];
		
		self.dateFormatter.timeZone = commit.commitTimeZone;
		NSString *timestamp = [self.dateFormatter stringFromDate:commit.commitDate];
		NSString *date = [NSString stringWithFormat:@"on %@", timestamp];
		
		strings = @[sha, @"→", branch.shortName, date];
	}
	
	NSArray *attributes = nil;
	{
		UIFont *font = self.infoLabel.font;
		
		NSDictionary *shaAttr = [NSAttributedString attributesWithTextColor:UIColor.commitNameTintColor font:font alignment:NSTextAlignmentNatural];
		NSDictionary *arrowAttr = [NSAttributedString attributesWithTextColor:UIColor.lightGrayColor font:font alignment:NSTextAlignmentNatural];
		NSDictionary *branchAttr = [NSAttributedString attributesWithTextColor:UIColor.branchNameTintColor font:font alignment:NSTextAlignmentNatural];
		NSDictionary *dateAttr = [NSAttributedString attributesWithTextColor:UIColor.lightGrayColor font:font alignment:NSTextAlignmentNatural];
		
		attributes = @[shaAttr, arrowAttr, branchAttr, dateAttr];
	}
	
	self.infoLabel.attributedText = [NSAttributedString stringByJoiningSimpleStrings:strings applyingAttributes:attributes joinString:@" "];
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

- (void)setShowsDayName:(BOOL)showsDayName {
	self.dateFormatter.dateFormat = showsDayName ? @"E, h:mm a" : @"h:mm a";
}

@end
