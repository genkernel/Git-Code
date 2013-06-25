//
//  GTCommit+Gitty.h
//  Gitty
//
//  Created by kernel on 23/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <ObjectiveGit/ObjectiveGit.h>

@interface GTCommit (Gitty)
@property (strong, nonatomic, readonly) NSCalendar *calendar;
@property (strong, nonatomic, readonly) NSDate *authorLocalDate;

- (BOOL)isLargeCommit;
@end
