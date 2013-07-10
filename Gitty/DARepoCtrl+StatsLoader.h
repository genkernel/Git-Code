//
//  DARepoCtrl+StatsLoader.h
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl.h"

@interface DARepoCtrl (StatsLoader)
- (void)loadStats;

// Private.
@property (strong, nonatomic, readonly) NSDateFormatter *yearMonthDayFormatter;
@end
