//
//  DAGitLatestDayStats.m
//  Gitty
//
//  Created by kernel on 20/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAGitLatestDayStats.h"

@interface DAGitLatestDayStats ()
@property (nonatomic, readwrite) NSUInteger latestDays;

@property (strong, nonatomic, readonly) NSDateFormatter *yearMonthDayFormatter;
@end

@implementation DAGitLatestDayStats
@dynamic yearMonthDayFormatter;

+ (instancetype)filterShowingLatestDaysOfCount:(NSUInteger)days {
	DAGitLatestDayStats *filter = self.new;
	filter.latestDays = days;
	
	return filter;
}

- (NSArray *)filterCommits:(NSArray *)list {
	NSMutableArray *filteredList = @[].mutableCopy;
	
	int filteredDays = 0;
	
	int latestChangesDay = 0;
//	const int todayDay = [self dayForToday];
	
	for (GTCommit *ci in list) {
		int day = [self dayForCommit:ci];
		/*
		 if (todayDay == day) {
		 [Logger info:@"Skipping todays commit."];
		 continue;
		 }*/
		
		if (latestChangesDay != 0 && day < latestChangesDay) {
			filteredDays++;
			
			if (filteredDays >= self.latestDays) {
				break;
			}
		}
		
		latestChangesDay = day;
		
		[filteredList addObject:ci];
	}
	
	return filteredList;
}
/*
- (BOOL)isValidCommit:(GTCommit *)commit {
	return NO;
}*/

#pragma mark Helpers

- (int)dayForToday {
	self.yearMonthDayFormatter.timeZone = NSTimeZone.defaultTimeZone;
	NSString *dateString = [self.yearMonthDayFormatter stringFromDate:NSDate.date];
	
	return dateString.intValue;
}

- (int)dayForCommit:(GTCommit *)ci {
	self.yearMonthDayFormatter.timeZone = ci.commitTimeZone;
	NSString *dateString = [self.yearMonthDayFormatter stringFromDate:ci.commitDate];
	
	return dateString.intValue;
}

#pragma mark Properties

- (NSDateFormatter *)yearMonthDayFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.dateFormat = @"yyyyMd";
	});
	return formatter;
}

@end
