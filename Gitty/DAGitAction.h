//
//  DAGitAction.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitActionDelegate.h"

extern int cred_acquire_userpass(git_cred **, const char *, const char *, unsigned int, void *);
extern int cred_acquire_ssh(git_cred **out, const char *url, const char *username_from_url, unsigned int allowed_types, void *payload);

@class DAGitManager;

@interface DAGitAction : NSObject {
@protected NSError *_completionError;
}
@property (weak, nonatomic, readonly) DAGitManager *manager;

@property (strong, nonatomic) DAGitActionDelegate *delegate;
@property (assign, nonatomic) dispatch_queue_t delegateQueue;

@property (weak, nonatomic, readonly) UIApplication *app;

- (void)exec;
- (void)finilize;
- (void)notifyDelegate:(void(^)())block;

@property (readonly) BOOL isCompletedSuccessfully;
@property (strong, nonatomic, readonly) NSError *completionError;
@end
