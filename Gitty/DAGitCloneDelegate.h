//
//  DAGitCloneDelegate.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitActionDelegate.h"

@interface DAGitCloneDelegate : DAGitActionDelegate
@property (strong, nonatomic) void (^transferProgressBlock)(const git_transfer_progress *);
@property (strong, nonatomic) void (^checkoutProgressBlock)(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps);
@end
