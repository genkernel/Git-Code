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
#import "DARepoCtrl+StatsLoader.h"

@implementation DARepoCtrl (GitFetcher)

- (void)loadCommitsInBranch:(GTBranch *)branch {
	NSError *err = nil;
	
	NSMutableArray *sections = NSMutableArray.new;
	NSMutableDictionary *commitsOnDate = NSMutableDictionary.new;
	NSMutableDictionary *authorsOnDate = NSMutableDictionary.new;
	
	GTEnumeratorOptions opts = GTEnumeratorOptionsTimeSort;
	[self.currentRepo enumerateCommitsBeginningAtSha:branch.sha sortOptions:opts error:&err usingBlock:^(GTCommit *commit, BOOL *stop) {
		
		self.dateSectionTitleFormatter.timeZone = commit.commitTimeZone;
		NSString *title = [self.dateSectionTitleFormatter stringFromDate:commit.commitDate];
		
		if (![sections containsObject:title]) {
			[sections addObject:title];
		}
		
		_authors[commit.author.name] = commit.author;
		
		NSMutableArray *commits = commitsOnDate[title];
		if (!commits) {
			commits = NSMutableArray.new;
			commitsOnDate[title] = commits;
		}
		[commits addObject:commit];
		
		NSMutableArray *authors = authorsOnDate[title];
		if (!authors) {
			authors = NSMutableArray.new;
			authorsOnDate[title] = authors;
		}
		if (![authors containsObject:commit.author]) {
			[authors addObject:commit.author];
		}
	}];
	
	_commitsOnDateSection = [NSDictionary dictionaryWithDictionary:commitsOnDate];
	_authorsOnDateSection = [NSDictionary dictionaryWithDictionary:authorsOnDate];
	_dateSections = [NSArray arrayWithArray:sections];
}

- (void)pull {
	__weak DARepoCtrl *ctrl = self;
	self.app.idleTimerDisabled = YES;
	
	DAGitPullDelegate *delegate = DAGitPullDelegate.new;
	delegate.transferProgressBlock = ^(const git_transfer_progress *progress){
		[Logger info:@"repo.pull progress: %d/%d", progress->received_objects, progress->total_objects];
		
		if (0 == progress->total_objects) {
			[Logger warn:@"0 total_objects specified during pulling."];
			return;
		}
		CGFloat percent = (CGFloat)progress->received_objects / progress->total_objects;
		[ctrl.pullingField setProgress:percent progressColor:UIColor.acceptingGreenColor backgroundColor:UIColor.blackColor];
	};
	delegate.finishBlock = ^(DAGitAction *pull, NSError *err){
		ctrl.app.idleTimerDisabled = NO;
		
		if (err && GIT_EEXISTS != err.code) {
			// Load stats anyway if nothing was updated.
			[ctrl loadStats];
			
			if (GIT_EEXISTS == err.code) {
				// Repo is up to date. No updates fetched.
			} else {
				[ctrl showErrorMessage:err.localizedDescription];
			}
			return;
		}
		
		[ctrl reloadFilters];
		[ctrl reloadCommits];
		
		if (isBranchOverlayVisible) {
			[self.branchPickerCtrl reloadWithBranches:self.remoteBranches];
		}
		
		[ctrl loadStats];
	};
	
	DAGitPull *pull = [DAGitPull pullForRepository:self.currentRepo fromServer:self.repoServer];
	pull.delegate = delegate;
	
	[self.git request:pull];
}

@end
