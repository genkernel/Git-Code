//
//  DAPeriodPicker+Helper.m
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAPeriodPicker+Helper.h"

@implementation DAPeriodPicker (Helper)

- (DAPeriod *)noLimit {
	return [DAPeriod periodWithTitle:NSLocalizedString(@"No limit", nil)];
}

- (DAPeriod *)today {
	return [DAPeriod periodWithTitle:NSLocalizedString(@"Today", nil)];
}

@end
