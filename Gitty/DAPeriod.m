//
//  DAFilterPeriod.m
//  Gitty
//
//  Created by kernel on 23/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAPeriod.h"

@interface DAPeriod ()
@property (strong, nonatomic, readwrite) NSString *title;
@end

@implementation DAPeriod
@dynamic date;

+ (instancetype)periodWithTitle:(NSString *)title {
	DAPeriod *period = self.new;
	period.title = title;
	
	return period;
}

- (NSDate *)date {
	return nil;
}

- (NSTimeInterval)today {
	NSCalendar *cal = NSCalendar.currentCalendar;
	
	// Get the hours, minutes, seconds
	NSUInteger flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *components = [cal components:flags fromDate:NSDate.date];
	
	NSTimeInterval period = components.hour HOURS;
	period += components.minute MINUTES;
	period += components.second SECONDS;
	
	return period;
}

@end
