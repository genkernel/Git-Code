//
//  DAGitUser.h
//  Gitty
//
//  Created by kernel on 17/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAGitUser : NSObject
+ (instancetype)userWithName:(NSString *)username password:(NSString *)password;

@property (copy, nonatomic) NSString *username, *password;
@end
