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

- (void)loadStatsHeadline {
	GTCommit *ci = self.lastDayStats.allCommits.firstObject;
	
	NSDateFormatter *formatter = NSDateFormatter.new;
	formatter.dateFormat = @"yyyy-MM-dd";
	formatter.timeZone = ci.commitTimeZone;
	
	NSDate *commitMidnight = [formatter dateFromString:[formatter stringFromDate:ci.commitDate]];
	
	NSDate *now = [formatter dateFromString:[formatter stringFromDate:NSDate.date]];
	
	NSTimeInterval interval = [now timeIntervalSinceDate:commitMidnight];
	
	const int secondsInOneDay = 60 * 60 * 24;
	int diff = interval / (1 * secondsInOneDay);
	
	NSString *dayString = nil;
	if (diff >= 365) {
		int years = diff / 365;
		dayString = years == 1 ? @"a year ago." : [NSString stringWithFormat:@"%d years ago.", years];
		
	} else if (diff >= 30) {
		int months = diff / 30;
		dayString = months == 1 ? @"a month ago." : [NSString stringWithFormat:@"%d months ago.", months];
	
	} else if (diff >= 7) {
		dayString = [NSString stringWithFormat:@"%d days ago.", diff];
		
	} else if (diff >= 2) {
		self.dayMonthFormatter.timeZone = ci.commitTimeZone;
		NSString *date = [self.dayMonthFormatter stringFromDate:ci.commitDate];
		
		dayString = [NSString stringWithFormat:@"on %@.", date];
		
	} else if (diff == 1) {
		dayString = @"yesterday.";
		
	} else {
		dayString = @"today";
	}
	
	[self loadStatsHeadlineWithDayPostfix:dayString];
}

- (void)loadStatsHeadlineWithDayPostfix:(NSString *)daysString {
	NSUInteger branchesCount = self.lastDayStats.heads.count;
	NSUInteger authorsCount = self.lastDayStats.authors.count;
	NSUInteger commitsCount = self.lastDayStats.allCommits.count;
	
	// Unique number string - space delimeter at the end.
	NSString *branchesCountString = [NSString stringWithFormat:@"%lu ", (unsigned long)branchesCount];
	// String uniqueness - 2 spaces.
	NSString *commitsCountString = [NSString stringWithFormat:@" %lu ", (unsigned long)commitsCount];
	// String uniqueness - leading space delimeter.
	NSString *authorsCountString = [NSString stringWithFormat:@" %lu", (unsigned long)authorsCount];
	
	NSString *branchesLiteral = branchesCount > 1 ? @"Branches updated with" : @"Branch updated with";
	NSString *commitsLiteral = commitsCount > 1 ? @"Commits\nby" : @"Commit\nby";
	NSString *authorsLiteral = authorsCount > 1 ? @" Authors " : @" Author ";
	
	
	NSArray *strings = @[branchesCountString, branchesLiteral, commitsCountString, commitsLiteral, authorsCountString, authorsLiteral, daysString];
	
	NSArray *attributes = @[
						 [self attributesWithForegroundColor:UIColor.acceptingGreenColor],
	   [self attributesWithForegroundColor:UIColor.whiteColor],
	   [self attributesWithForegroundColor:UIColor.acceptingBlueColor],
	   [self attributesWithForegroundColor:UIColor.whiteColor],
	   [self attributesWithForegroundColor:UIColor.cancelingRedColor],
	   [self attributesWithForegroundColor:UIColor.whiteColor],
		[self attributesWithForegroundColor:UIColor.whiteColor]];
	
	self.headlineLabel.attributedText = [NSAttributedString stringByJoiningSimpleStrings:strings applyingAttributes:attributes joinString:nil];
}

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

- (NSDateFormatter *)dayMonthFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.dateFormat = @"MMMM d";
	});
	return formatter;
}

@end
