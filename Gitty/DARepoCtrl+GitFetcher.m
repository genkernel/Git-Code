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

- (void)loadCommitsInBranch:(GTBranch *)branch betweenNowAndDate:(NSDate *)date {
	NSError *err = nil;
	NSMutableSet *zones = NSMutableSet.new;
	
	NSMutableArray *sections = NSMutableArray.new;
	NSMutableDictionary *commitsOnDate = NSMutableDictionary.new;
	NSMutableDictionary *authorsOnDate = NSMutableDictionary.new;
	
	GTEnumeratorOptions opts = GTEnumeratorOptionsTimeSort;
	[self.currentRepo enumerateCommitsBeginningAtSha:branch.sha sortOptions:opts error:&err usingBlock:^(GTCommit *commit, BOOL *stop) {
		[zones addObject:commit.commitTimeZone];
		
		NSDate *commitLocalDate = commit.commitDate;
		
		[Logger info:@"%@", commitLocalDate];
		
		BOOL isCommitEarlier = NSOrderedAscending == [commitLocalDate compare:date];
		if (isCommitEarlier) {
			*stop = YES;
			return;
		}
		
		self.dateSectionTitleFormatter.timeZone = commit.commitTimeZone;
		NSString *title = [self.dateSectionTitleFormatter stringFromDate:commitLocalDate];
		
		if (![sections containsObject:title]) {
			[sections addObject:title];
		}
		
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
