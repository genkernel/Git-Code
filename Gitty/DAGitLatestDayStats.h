//
//  DAGitLatestDayStats.h
//  Gitty
//
//  Created by kernel on 20/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAGitOperationFilter.h"

@interface DAGitLatestDayStats : NSObject <DAGitOperationFilter>
+ (instancetype)filterShowingLatestDaysOfCount:(NSUInteger)days;

@property (nonatomic, readonly) NSUInteger latestDays;
@end
