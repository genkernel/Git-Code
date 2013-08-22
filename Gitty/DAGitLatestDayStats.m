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
@end

@implementation DAGitLatestDayStats

+ (instancetype)filterShowingLatestDaysOfCount:(NSUInteger)days {
	DAGitLatestDayStats *filter = self.new;
	filter.latestDays = days;
	
	return filter;
}

- (NSArray *)filterCommits:(NSArray *)list {
	NSMutableArray *filteredList = @[].mutableCopy;
	
	int filteredDays = 0;
	int latestChangesDay = 0;
	
	for (GTCommit *ci in list) {
		int day = [self universalDayNumberForCommit:ci];
		
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

- (int)universalDayNumberForCommit:(GTCommit *)ci {
	NSDateFormatter *formatter = self.yearMonthDayFormatter;
	
	formatter.timeZone = ci.commitTimeZone;
	NSString *dateString = [formatter stringFromDate:ci.commitDate];
	
	return dateString.intValue;
}

- (NSDateFormatter *)yearMonthDayFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.dateFormat = @"yyyyMMdd";
	});
	return formatter;
}

@end
