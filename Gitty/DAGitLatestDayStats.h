//
//  DAGitLatestDayStats.h
//  Gitty
//
//  Created by kernel on 20/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAGitOperationBaseFilter.h"

@interface DAGitLatestDayStats : DAGitOperationBaseFilter
+ (instancetype)filterShowingLatestDaysOfCount:(NSUInteger)days;

@property (nonatomic, readonly) NSUInteger latestDays;
@end
