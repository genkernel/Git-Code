//
//  NSDictionary+RecentRepo.h
//  Gitty
//
//  Created by kernel on 25/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (RecentRepo)
@property (strong, nonatomic, readonly) NSDate *lastAccessDate;
@property (strong, nonatomic, readonly) NSString *relativePath, *activeBranchName;
@end
