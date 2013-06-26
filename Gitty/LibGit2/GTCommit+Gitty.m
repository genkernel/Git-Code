//
//  GTCommit+Gitty.m
//  Gitty
//
//  Created by kernel on 23/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "GTCommit+Gitty.h"

@implementation GTCommit (Gitty)
@dynamic authorLocalDate;
@dynamic calendar;

- (NSCalendar *)calendar {
	static NSCalendar *calendar = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		calendar = NSCalendar.currentCalendar;
	});
	return calendar;
}

- (NSDate *)authorLocalDate {
	/*
	NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
	
	// Format date with current timezone.
	NSDateComponents *components = [self.calendar components:flags fromDate:self.commitDate];
	components.timeZone = self.commitTimeZone;
	
	return [self.calendar dateFromComponents:components];*/
	NSInteger seconds = [self.commitTimeZone secondsFromGMTForDate:self.commitDate];
	return [self.commitDate dateByAddingTimeInterval:seconds];
}

- (BOOL)isLargeCommit {
	BOOL isInitialCommit = 0 == self.parents.count;
	BOOL hasMultipleParents = self.parents.count >= 2;
	
	return isInitialCommit || hasMultipleParents;
}

@end
