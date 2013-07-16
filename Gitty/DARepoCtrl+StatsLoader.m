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

static NSTimeInterval OneDayInterval = 1 DAYS;
static NSUInteger CommitsExtraCheckingThreshold = 5;

@implementation DARepoCtrl (StatsLoader)
@dynamic yearMonthDayFormatter, dayOfWeekFormatter;
@dynamic dayOfWeekTitleFormatter, dayOfMonthTitleFormatter;

- (void)loadStats {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		_statsCommitsCount = 0;
		
		_statsCommitsByAuthor = NSMutableDictionary.new;
		_statsCommitsByBranch = NSMutableDictionary.new;
		
		for (GTBranch *branch in self.remoteBranches) {
			// TODO: dispatch in extra background queue for large queries (large stats).
			[self loadStatsForBranch:branch];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			BOOL hasStatsToShow = _statsCommitsCount > 0;
			
			if (hasStatsToShow) {
				[self loadStatsHeadline];
				[self reloadStatsCommitsWithMode:DACommitsListByAuthorMode];
			} else {
				[self setStatsContainerMode:DAStatsHiddenMode animated:NO];
			}
			
			[self setPullingViewVisible:NO animated:YES];
			[self addForgetButton];
		});
	});
}

- (void)loadStatsForBranch:(GTBranch *)branch {
	NSDate *todayDate = NSDate.date;
	
	NSString *dateString = [self.dayOfWeekFormatter stringFromDate:todayDate];
	int todayDayOfWeek = dateString.intValue;
	[Logger info:@"Today.dayOfWeek: %d", todayDayOfWeek];
	
	BOOL isCollectingWeekendStats = NO;
	
	NSTimeInterval interval = -OneDayInterval;
	if (1 == todayDayOfWeek) {
		// Sunday. Collect Stats for Fri + Sat.
		interval *= 2;
		isCollectingWeekendStats = YES;
	} else if (2 == todayDayOfWeek) {
		// Monday. Collect Stats for Fri + weekend.
		interval *= 3;
		isCollectingWeekendStats = YES;
	}
	
	NSDate *yesterdayDate = [NSDate dateWithTimeIntervalSinceNow:interval];
	
	self.yearMonthDayFormatter.timeZone = NSTimeZone.localTimeZone;
	dateString = [self.yearMonthDayFormatter stringFromDate:yesterdayDate];
	int yesterday = [dateString intValue];
	
	dateString = [self.yearMonthDayFormatter stringFromDate:todayDate];
	int today = [dateString intValue];
	
	if (isCollectingWeekendStats) {
		_statsCustomTitle = [self.dayOfWeekTitleFormatter stringFromDate:yesterdayDate];
		_statsCustomHint = NSLocalizedString(@"+ weekend", nil);
	} else {
		_statsCustomTitle = NSLocalizedString(@"Yesterday", nil);
		_statsCustomHint = [self.dayOfMonthTitleFormatter stringFromDate:yesterdayDate];
	}
	
	NSError *err = nil;
	NSComparisonResult (^isYesterdaysCommit)(GTCommit *) = ^(GTCommit *commit){
		self.yearMonthDayFormatter.timeZone = commit.commitTimeZone;
		NSString *dateString = [self.yearMonthDayFormatter stringFromDate:commit.commitDate];
		
		int day = [dateString intValue];
		
		BOOL isWeekend = day >= yesterday && day < today;
		if (day == yesterday || isWeekend) {
			return NSOrderedSame;
		}
		
		return day < yesterday ? NSOrderedAscending : NSOrderedDescending;
	};
	
	__block NSUInteger threshold = 0;
	
	NSString *branchName = branch.shortName;
	NSMutableArray *commitsByBranch = [NSMutableArray arrayWithCapacity:30];
	NSMutableDictionary *commitsByAuthor = NSMutableDictionary.new;
	
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
		
		_statsCommitsCount++;
		
		[commitsByBranch addObject:commit];
		
		NSMutableArray *commits = commitsByAuthor[commit.author.name];
		if (!commits) {
			commits = [NSMutableArray arrayWithCapacity:30];
			commitsByAuthor[commit.author.name] = commits;
		}
		[commits addObject:commit];
		
		NSString *addr = [NSString stringWithFormat:@"0x%X", (int)commit];
		_branches[addr] = branch;
		_authors[commit.author.name] = commit.author;
	}];
	
	if (commitsByBranch.count) {
		_statsCommitsByBranch[branchName] = commitsByBranch;
	}
	
	for (NSString *author in commitsByAuthor.allKeys) {
		NSMutableArray *localCommits = commitsByAuthor[author];
		
		NSMutableArray *allCommits = _statsCommitsByAuthor[author];
		if (allCommits) {
			[self mergeNewBranchCommits:localCommits intoArray:allCommits];
		} else {
			_statsCommitsByAuthor[author] = localCommits;
		}
	}
}

- (void)mergeNewBranchCommits:(NSArray *)commits intoArray:(NSMutableArray *)branch {
	if (branch.count == 0) {
		[branch addObjectsFromArray:commits];
		return;
	}
	
	NSUInteger headIdx = 0, insertIdx = 0;
	NSArray *sourceBranch = [NSArray arrayWithArray:branch];
	
	NSMutableArray *tailCommits = [NSMutableArray arrayWithCapacity:commits.count];
	
	for (GTCommit *commit in commits) {
		if (headIdx == sourceBranch.count) {
			[branch addObject:commit];
			continue;
		}
		
		GTCommit *head = sourceBranch[headIdx];
		
		NSComparisonResult result = [commit.commitDate compare:head.commitDate];
		if (NSOrderedAscending == result) {
//			[Logger info:@"%@ < %@", commit.shortSha, head.shortSha];
			[tailCommits addObject:commit];
			headIdx++;
		} else {
//			[Logger info:@"%@ >= %@", commit.shortSha, head.shortSha];
			[branch insertObject:commit atIndex:insertIdx];
			insertIdx++;
		}
	}
	
	[branch addObjectsFromArray:tailCommits];
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

- (NSDateFormatter *)dayOfWeekFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		// Using .systemLocal ensures that firstDayOfWeek is Sunday (always, as opposite to user's locale).
		formatter.locale = NSLocale.systemLocale;
		formatter.timeZone = NSTimeZone.localTimeZone;
		formatter.dateFormat = @"e";
	});
	return formatter;
}

- (NSDateFormatter *)dayOfWeekTitleFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.timeZone = NSTimeZone.localTimeZone;
		formatter.dateFormat = @"EEEE";
	});
	return formatter;
}

- (NSDateFormatter *)dayOfMonthTitleFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.timeZone = NSTimeZone.localTimeZone;
		formatter.dateFormat = @"d MMM";
	});
	return formatter;
}

@end
