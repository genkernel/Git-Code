//
//  DAFlurry.h
//  Gitty
//
//  Created by kernel on 2/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "Flurry.h"
#import "DAFlurryEvent.h"

@interface DAFlurry : NSObject
+ (instancetype)analytics;

- (void)start;
- (void)logEvent:(DAFlurryEvent *)event;
- (void)startTimedEvent:(DAFlurryEvent *)event;
- (void)endTimedEvent:(DAFlurryEvent *)event;
@end

extern NSString *GitActionDiff;
extern NSString *GitActionCloneFailed, *GitActionPullFailed;
extern NSString *GitActionCloneSuccess, *GitActionPullSuccess;
extern NSString *GitServerGithub, *GitServerBitbucket, *GitServerCustom;

extern NSString *WorkflowActionDiffPortrait, *WorkflowActionDiffLandscape;
//extern NSString *WorkflowActionBranchListShown, *WorkflowActionBranchListHidden;

//extern NSString *WorkflowActionBranchListTouch, *WorkflowActionBranchListDrag;

extern NSString *WorkflowActionRepoForgotten, *WorkflowActionRepoRemoved, *WorkflowActionRepoAllRemoved;
extern NSString *WorkflowActionBranchSwitched, *WorkflowActionTagSwitched, *WorkflowActionCustomServerCreated;
extern NSString *WorkflowActionByBranchRevealed, *WorkflowActionByAuthorRevealed;

extern NSString *WorkflowActionSSHKeysAdded, *WorkflowActionBadSSHKeysFound, *WorkflowActionLoginUsingCredentials, *WorkflowActionUnboundSSHKeysFound;

extern NSString *WorkflowActionServerRemoved;
extern NSString *WorkflowActionRepoCreatedExternallyViaProtocolScheme;

@interface DAFlurry (GittyEvents)
+ (void)logSuccessServer:(NSString *)name;
+ (void)logInvalidServer:(NSString *)name;

+ (void)logProtocol:(NSString *)name;
+ (void)logGitAction:(NSString *)name;
+ (void)logWorkflowAction:(NSString *)name;

+ (void)logScreenAppear:(NSString *)name;
+ (void)logScreenDisappear:(NSString *)name;
@end
