//
//  DAGitClone.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitAction.h"
#import "DAGitCloneDelegate.h"

@interface DAGitClone : DAGitAction
+ (instancetype)cloneRepoWithName:(NSString *)name fromServer:(DAGitServer *)server;

@property (strong, nonatomic) DAGitCloneDelegate *delegate;
@property (strong, nonatomic) DAGitUser *authenticationUser;

@property (strong, nonatomic, readonly) GTRepository *clonedRepo;
@end
