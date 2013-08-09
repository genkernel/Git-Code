//
//  DAFlurry.m
//  Gitty
//
//  Created by kernel on 2/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAFlurry.h"

@implementation DAFlurry

+ (instancetype)analytics {
	static id instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	
	return instance;
}

- (void)start {
	[Flurry startSession:@"TTMTVBZW6X8MKMCWJGDS"];
}

- (void)logEvent:(DAFlurryEvent *)event {
//	[Logger info:@"%@: %@", event.name, event.params];
	
	[Flurry logEvent:event.name withParameters:event.params];
}

- (void)startTimedEvent:(DAFlurryEvent *)event {
//	[Logger info:@" ->  %@", event.params];
	
	[Flurry logEvent:event.name withParameters:event.params timed:YES];
}

- (void)endTimedEvent:(DAFlurryEvent *)event {
//	[Logger info:@" <-  %@", event.params];
	
	[Flurry logEvent:event.name withParameters:event.params];
}

@end


NSString *GitActionDiff = @"Diff";
NSString *GitActionCloneFailed = @"Failed Clone(s)", *GitActionPullFailed = @"Failed Pull(s)";
NSString *GitActionCloneSuccess = @"Success Clone(s)", *GitActionPullSuccess = @"Success Pull(s)";

NSString *GitServerGithub = @"Github", *GitServerBitbucket = @"Bitbucket", *GitServerCustom = @"Custom";

NSString *WorkflowActionDiffPortrait = @"Diff - Portrait", *WorkflowActionDiffLandscape = @"Diff - Landscape";

NSString *WorkflowActionBranchListShown = @"BranchList Opened", *WorkflowActionBranchListHidden = @"BranchList Closed";

NSString *WorkflowActionBranchListTouch = @"BranchList - Touch", *WorkflowActionBranchListDrag = @"BranchList - Drag";

NSString *WorkflowActionRepoForgotten = @"Repo - Forgotten (files only)", *WorkflowActionRepoRemoved = @"Repo - Removed (completely)", *WorkflowActionRepoAllRemoved = @"Repo - All removed";
NSString *WorkflowActionBranchSwitched = @"Branch switched", *WorkflowActionTagSwitched = @"Tag switched", *WorkflowActionCustomServerCreated = @"+Custom server created";
NSString *WorkflowActionByBranchRevealed = @"Stats - byBranch", *WorkflowActionByAuthorRevealed = @"Stats - byAuthor";

NSString *WorkflowActionSSHKeysAdded = @"SSH keys added", *WorkflowActionBadSSHKeysFound = @"Bad SSH keys found", *WorkflowActionLoginUsingCredentials = @"Login with Credentials", *WorkflowActionUnboundSSHKeysFound = @"SSH not bound to Server found.";

@implementation DAFlurry (GittyEvents)

+ (void)logSuccessServer:(NSString *)name {
	[DAFlurry.analytics logEvent:[DAFlurryEvent eventWithName:@"Servers" params:@{@"Success Servers": name}]];
}

+ (void)logInvalidServer:(NSString *)name {
	[DAFlurry.analytics logEvent:[DAFlurryEvent eventWithName:@"Servers" params:@{@"Failed Servers": name}]];
}

+ (void)logProtocol:(NSString *)name {
	[DAFlurry.analytics logEvent:[DAFlurryEvent eventWithName:@"Servers" params:@{@"Protocols": name}]];
}

+ (void)logGitAction:(NSString *)name {
	[DAFlurry.analytics logEvent:[DAFlurryEvent eventWithName:@"Git Operations" params:@{@"Actions": name}]];
}

+ (void)logWorkflowAction:(NSString *)name {
	[DAFlurry.analytics logEvent:[DAFlurryEvent eventWithName:@"Workflow Actions" params:@{@"Actions": name}]];
}

+ (void)logScreenAppear:(NSString *)name {
	[DAFlurry.analytics startTimedEvent:[DAFlurryEvent eventWithName:@"Screen Timings" params:@{@"Periods": name}]];
}

+ (void)logScreenDisappear:(NSString *)name {
	[DAFlurry.analytics endTimedEvent:[DAFlurryEvent eventWithName:@"Screen Timings" params:@{@"Periods": name}]];
}

@end
