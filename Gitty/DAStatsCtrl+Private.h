//
//  DAStatsCtrl+Private.h
//  Gitty
//
//  Created by kernel on 9/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatsCtrl.h"
#import "DARepoCtrl.h"

@interface DAStatsCtrl ()
@property (strong, nonatomic, readonly) DARepoCtrl *repoCtrl;

@property (strong, nonatomic, readonly) DARepoWalk *repoStats, *lastDayStats;
@end
