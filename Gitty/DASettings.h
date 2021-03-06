//
//  DASettings.h
//  Gitty
//
//  Created by kernel on 24/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DASettings : NSObject
+ (instancetype)currentUserSettings;

- (int)doAction:(NSString *)name;
- (int)countForAction:(NSString *)name;

@property (nonatomic) BOOL didPresentRevealStatsHint;
@property (nonatomic) BOOL didPresentSwipeToServerHint;
@end
