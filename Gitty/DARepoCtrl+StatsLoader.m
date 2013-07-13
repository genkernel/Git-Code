//
//  DARepoCtrl+StatsLoader.m
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl+StatsLoader.h"
#import "DARepoCtrl+Private.h"
#import "DARepoCtrl+Animation.h"

static NSTimeInterval DayInterval = 17 DAYS;
static NSUInteger CommitsExtraCheckingThreshold = 5;

@implementation DARepoCtrl (StatsLoader)
@dynamic yearMonthDayFormatter;

- (void)loadStats {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		_statsCommitsByAuthor = NSMutableDictionary.new;
		_statsCommitsByBranch = NSMutableDictionary.new;
		
		for (GTBranch *branch in self.remoteBranches) {
			// TODO: dispatch in extra background queue for large queries (large stats).
			[self loadStatsForBranch:branch];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self loadStatsHeadline];
			
			[self reloadStatsCommitsWithMode:DACommitsListByAuthorMode];
			
			[self setPullingViewVisible:NO animated:YES];
			[self addForgetButton];
		});
	});
}

- (void)loadStatsForBranch:(GTBranch *)branch {
	NSError *err = nil;
	
//	NSDate *yesteray = [NSDate dateWithTimeIntervalSinceNow:DayInterval];
	
//	NSCalendar *calendar = NSCalendar.autoupdatingCurrentCalendar;
	NSDate *yesterdayDate = [NSDate dateWithTimeIntervalSinceNow:-DayInterval];
	/*
	NSCalendarUnit parts = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *yesterdayComponents = [calendar components:parts fromDate:yesterayDate];
	*/
	self.yearMonthDayFormatter.timeZone = NSTimeZone.localTimeZone;
	NSString *dateString = [self.yearMonthDayFormatter stringFromDate:yesterdayDate];
	int yesterday = [dateString intValue];
	
	NSComparisonResult (^isYesterdaysCommit)(GTCommit *) = ^(GTCommit *commit){
		self.yearMonthDayFormatter.timeZone = commit.commitTimeZone;
		NSString *dateString = [self.yearMonthDayFormatter stringFromDate:commit.commitDate];
		
		int day = [dateString intValue];
		
		[Logger info:@"%d - %d = %d", day, yesterday, day - yesterday];
		
		return day - yesterday;
	};
	
	__block NSUInteger threshold = 0;
	
	NSString *branchName = branch.name.lastPathComponent;
	NSMutableArray *commitsByBranch = [NSMutableArray arrayWithCapacity:30];
	
	GTEnumeratorOptions opts = GTEnumeratorOptionsTimeSort;
	[self.currentRepo enumerateCommitsBeginningAtSha:branch.sha sortOptions:opts error:&err usingBlock:^(GTCommit *commit, BOOL *stop) {
		
		NSComparisonResult result = isYesterdaysCommit(commit);
		if (NSOrderedAscending == result) {
			threshold++;
			
			if (threshold >= CommitsExtraCheckingThreshold) {
				*stop = YES;
			}
			return;
		} else if (NSOrderedSame != result) {
			// != Yesterday.
			return;
		}
		
		[commitsByBranch addObject:commit];
		
		NSMutableArray *commitsByAuthor = _statsCommitsByAuthor[commit.author.name];
		if (!commitsByAuthor) {
			commitsByAuthor = [NSMutableArray arrayWithCapacity:30];
			_statsCommitsByAuthor[commit.author.name] = commitsByAuthor;
		}
		[commitsByAuthor addObject:commit];
		
		_branches[commit.shortSha] = branch;
		_authors[commit.author.name] = commit.author;
	}];
	
	if (commitsByBranch.count) {
		_statsCommitsByBranch[branchName] = commitsByBranch;
	}
}

#pragma mark Properties

- (NSDateFormatter *)yearMonthDayFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.dateFormat = @"yyyyMd";
	});
	return formatter;
}

@end
