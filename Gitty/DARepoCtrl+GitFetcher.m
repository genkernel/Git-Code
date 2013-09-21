//
//  DARepoCtrl+GitFetcher.m
//  Gitty
//
//  Created by kernel on 4/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl+GitFetcher.h"
#import "DARepoCtrl+Private.h"
#import "DARepoCtrl+Animation.h"

@implementation DARepoCtrl (GitFetcher)

- (void)pull {
	__weak DARepoCtrl *ctrl = self;
	self.app.idleTimerDisabled = YES;
	
	DAGitPullDelegate *delegate = DAGitPullDelegate.new;
	__weak DAGitPullDelegate *thisDelegate = delegate;
	
	delegate.transferProgressBlock = ^(const git_transfer_progress *progress){
		[Logger info:@"repo.pull progress: %d/%d", progress->received_objects, progress->total_objects];
		
		if (0 == progress->total_objects) {
			[Logger warn:@"0 total_objects specified during pulling."];
			return;
		}
		
		thisDelegate.receivedObjects = progress->received_objects;
		
		CGFloat percent = (CGFloat)progress->received_objects / progress->total_objects;
		
		[ctrl.pullingField setProgress:percent progressColor:UIColor.acceptingGreenColor backgroundColor:UIColor.blackColor];
	};
	delegate.finishBlock = ^(DAGitAction *pull, NSError *err){
		ctrl.app.idleTimerDisabled = NO;
		
		BOOL hasZeroReceivedObjects = thisDelegate.receivedObjects == 0;
		
		if (err && hasZeroReceivedObjects) {
			// Load stats anyway if nothing was updated.
			[ctrl loadStats];
			
			if (GIT_EEXISTS == err.code) {
				// Repo is up to date. No updates fetched.
			} else {
				Alert *alert = [Alert errorAlertWithMessage:err.localizedDescription];
				[AlertQueue.queue enqueueAlert:alert];
				
				[DAFlurry logGitAction:GitActionPullFailed];
			}
			
			return;
		}
		
		[ctrl reloadFilters];
		[ctrl reloadCommitsAndOptionallyTable:YES];
		
		if (isBranchOverlayVisible) {
			self.branchPickerCtrl.tags = self.tags;
			self.branchPickerCtrl.branches = self.remoteBranches;
			
			[self.branchPickerCtrl reloadUI];
		}
		
		[ctrl loadStats];
		
		[DAFlurry logGitAction:GitActionPullSuccess];
	};
	
	DAGitPull *pull = [DAGitPull pullForRepository:self.currentRepo fromServer:self.repoServer];
	pull.delegate = delegate;
	pull.authenticationUser = self.authUser;
	
	[self.git request:pull];
}

- (void)loadStats {
	DARepoWalk *walk = [DARepoWalk walkForRepo:self.currentRepo];
	
	[self.stats performAsyncOperation:walk completionHandler:^{
		[_statsCtrl reloadStatsData:walk];
		
		[self setPullingVisible:NO animated:YES];
		[self addBranchesButton];
	}];
}

@end
