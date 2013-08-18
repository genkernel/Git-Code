//
//  DAStatsCtrl+Headline.m
//  Gitty
//
//  Created by kernel on 9/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatsCtrl+Headline.h"
#import "DAStatsCtrl+Private.h"

@implementation DAStatsCtrl (Headline)

- (void)resetStatsHeadline {
	self.headlineLabel.attributedText = NSAttributedString.new;
}
/*
- (void)loadStatsHeadline {
	// Unique number string - space delimeter at the end.
	NSString *branchesCount = [NSString stringWithFormat:@"%d ", self.repoCtrl.statsCommitsByBranch.count];
	// String uniqueness - 2 spaces.
	NSString *commitsCount = [NSString stringWithFormat:@" %d ", self.repoCtrl.statsCommitsCount];
	// String uniqueness - leading space delimeter.
	NSString *authorsCount = [NSString stringWithFormat:@" %d", self.repoCtrl.statsCommitsByAuthor.count];
	
	NSString *branchesLiteral = self.repoCtrl.statsCommitsByBranch.count > 1 ? @"Branches updated with" : @"Branch updated with";
	NSString *commitsLiteral = self.repoCtrl.statsCommitsCount > 1 ? @"Commits\nby" : @"Commit\nby";
	NSString *authorsLiteral = self.repoCtrl.statsCommitsByAuthor.count > 1 ? @" Authors " : @" Author ";
	
	
	NSArray *strings = @[branchesCount, branchesLiteral, commitsCount, commitsLiteral, authorsCount, authorsLiteral, self.headlineSinceDayText];
	
	NSArray *attributes = @[
						 [self attributesWithForegroundColor:UIColor.acceptingGreenColor],
	   [self attributesWithForegroundColor:UIColor.whiteColor],
	   [self attributesWithForegroundColor:UIColor.acceptingBlueColor],
	   [self attributesWithForegroundColor:UIColor.whiteColor],
	   [self attributesWithForegroundColor:UIColor.cancelingRedColor],
	   [self attributesWithForegroundColor:UIColor.whiteColor],
		[self attributesWithForegroundColor:UIColor.whiteColor]];
	
	self.headlineLabel.attributedText = [NSAttributedString stringByJoiningSimpleStrings:strings applyingAttributes:attributes joinString:nil];
}*/

- (NSDictionary *)attributesWithForegroundColor:(UIColor *)color {
	static NSMutableDictionary *attributes = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableParagraphStyle *paragraph = NSMutableParagraphStyle.new;
		paragraph.alignment = NSTextAlignmentCenter;
		
		attributes = NSMutableDictionary.new;
		attributes[NSFontAttributeName] = self.headlineLabel.font;
		attributes[NSParagraphStyleAttributeName] = paragraph;
	});
	
	attributes[NSForegroundColorAttributeName] = color;
	return attributes.copy;
}

@end
