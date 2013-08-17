//
//  DAGitStats.h
//  Gitty
//
//  Created by kernel on 17/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAGitStats : NSObject
+ (instancetype)statsForRepository:(GTRepository *)repo;
@end
