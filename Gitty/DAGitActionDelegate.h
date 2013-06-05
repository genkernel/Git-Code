//
//  DAGitActionDelegate.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DAGitAction;

@interface DAGitActionDelegate : NSObject
@property (strong, nonatomic) void (^finishBlock)(DAGitAction *, NSError *);
@end
