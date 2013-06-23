//
//  DAPeriodPicker+Helper.m
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAPeriodPicker+Helper.h"

@implementation DAPeriodPicker (Helper)

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
