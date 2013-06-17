//
//  DAGitUser.m
//  Gitty
//
//  Created by kernel on 17/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitUser.h"

@implementation DAGitUser

+ (instancetype)userWithName:(NSString *)username password:(NSString *)password {
	DAGitUser *user = self.new;
	user.username = username;
	user.password = password;
	return user;
}

@end
