//
//  DARepoCtrl+GitFetcher.m
//  Gitty
//
//  Created by kernel on 4/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl+GitFetcher.h"
#import "DARepoCtrl+Animation.h"

@implementation DARepoCtrl (GitFetcher)

- (NSArray *)loadCommitsInBranch:(GTBranch *)branch betweenNowAndDate:(NSDate *)date {
	NSError *err = nil;
	NSMutableArray *commits = [NSMutableArray arrayWithCapacity:2000];
	
	GTEnumeratorOptions opts = GTEnumeratorOptionsTimeSort;
	[self.currentRepo enumerateCommitsBeginningAtSha:branch.sha sortOptions:opts error:&err usingBlock:^(GTCommit *commit, BOOL *stop) {
		[commits addObject:commit];
	}];
	
	return commits;
}

- (void)pull {
	DAGitPullDelegate *delegate = DAGitPullDelegate.new;
	delegate.transferProgressBlock = ^(const git_transfer_progress *progress){
		[Logger info:@"pull progress: %d/%d", progress->received_objects, progress->total_objects];
		
		if (0 == progress->total_objects) {
			[Logger warn:@"0 total_objects specified during pulling."];
			return;
		}
		CGFloat percent = (CGFloat)progress->received_objects / progress->total_objects;
		[self.pullingField setProgress:percent progressColor:UIColor.acceptingGreenColor backgroundColor:UIColor.blackColor];
	};
	delegate.finishBlock = ^(DAGitAction *pull, NSError *err){
		if (err) {
			[self showErrorAlert:err.localizedDescription];
		}
		
		[self setPullingViewVisible:NO animated:YES];
		
		[self reloadFilters];
		[self reloadCommits];
	};
	
	DAGitPull *pull = [DAGitPull pullForRepository:self.currentRepo];
	pull.delegate = delegate;
	
	[self.git request:pull];
}

@end
