//
//  DABranchWalk.m
//  Gitty
//
//  Created by kernel on 18/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DABranchWalk.h"

@interface DABranchWalk ()
@property (strong, nonatomic) GTBranch *branch;
@property (strong, nonatomic) GTTag *tag;

@property (strong, nonatomic, readonly) GTRepository *repo;
@property (strong, nonatomic, readonly) NSString *startSHA;

@property (strong, nonatomic, readonly) NSDateFormatter *defaultSectionDateFormatter;

@property (strong, nonatomic, readonly) NSString *nextCommitSHA;
@end

@implementation DABranchWalk
@dynamic repo, authors;

+ (instancetype)walkForBranch:(GTBranch *)branch {
	DABranchWalk *walk = self.new;
	walk.branch = branch;
	
	return walk;
}

+ (instancetype)walkForTag:(GTTag *)tag {
	DABranchWalk *walk = self.new;
	walk.tag = tag;
	
	return walk;
}

- (id)init {
	self = [super init];
	if (self) {
		self.dateSectionTitleFormatter = self.defaultSectionDateFormatter;
	}
	return self;
}

- (GTSignature *)authorForCommit:(GTCommit *)commit {
	NSString *email = self.commitAuthorMap[commit.SHA];
	return self.authorRefs[email];
}

- (void)perform {
	assert(self.repo);
	
	_hasMoreCommitsToProcess = YES;
	
	NSUInteger processedCommitsCount = 0;
	[NSObject startMeasurement];
	{
		processedCommitsCount = [self loadSections];
	}
	double period = [NSObject endMeasurement];
	[Logger info:@"Branch statistics gathered for %d commits in %.2f.", processedCommitsCount, period];
}
/*
- (NSUInteger)countAllCommits {
	NSError *err = nil;
	GTEnumerator *iter = [GTEnumerator.alloc initWithRepository:self.repo error:&err];
	
	if (![iter pushSHA:self.startSHA error:&err]) {
		[Logger error:@"Failed to pushSHA to count commits."];
		return 0;
	}
	
	return [iter countRemainingObjects:&err];
}*/

- (NSUInteger)loadSections {
	NSUInteger processedCommitsCount = 0;
	
	NSMutableDictionary *authorRefs = _authorRefs ? _authorRefs.mutableCopy : @{}.mutableCopy;
	NSMutableDictionary *commitAuthorMap = _commitAuthorMap ? _commitAuthorMap.mutableCopy : @{}.mutableCopy;
	
	NSMutableArray *sections = _dateSections ? _dateSections.mutableCopy : @[].mutableCopy;
	NSMutableDictionary *commitsOnDate = _commitsOnDateSection ? _commitsOnDateSection.mutableCopy : @{}.mutableCopy;
	
	
	NSError *err = nil;
	GTEnumerator *iter = [GTEnumerator.alloc initWithRepository:self.repo error:&err];
	
	NSString *sha = self.nextCommitSHA ? self.nextCommitSHA : self.startSHA;
	if (![iter pushSHA:sha error:&err]) {
		[Logger error:@"Failed to pushSHA to enumarate commits."];
		return 0;
	}
	
	[iter resetWithOptions:GTEnumeratorOptionsTimeSort];
	
	
	size_t idx = self.filter.processedCommitsCount;
	
	for ( ; YES; idx++) {
//	for (GTCommit *commit in self.commits) {
		BOOL success = NO;
		NSError *err = nil;
		
		GTCommit *commit = [iter nextObjectWithSuccess:&success error:&err];
		
		if (!success) {
			[Logger error:@"Failed to retrieve next commit. %@", err];
			break;
		}
		
		if (!commit) {
			_hasMoreCommitsToProcess = NO;
			break;
		}
		
		_nextCommitSHA = commit.SHA;
		
		if (![self.filter filterNextCommit:commit]) {
			break;
		}
		
		self.dateSectionTitleFormatter.timeZone = commit.commitTimeZone;
		NSString *title = [self.dateSectionTitleFormatter stringFromDate:commit.commitDate];
		
		if (![sections containsObject:title]) {
			[sections addObject:title];
		}
		
		@autoreleasepool {
			GTSignature *author = commit.author;
			
			authorRefs[author.email] = author;
			commitAuthorMap[commit.SHA] = author.email;
			
			NSMutableArray *commits = commitsOnDate[title];
			if (!commits) {
				commits = NSMutableArray.new;
				commitsOnDate[title] = commits;
			}
			[commits addObject:commit];
		}
		
		processedCommitsCount++;
	}
	
	_dateSections = sections.copy;
	_commitsOnDateSection = commitsOnDate.copy;
	
	_authorRefs = authorRefs.copy;
	_commitAuthorMap = commitAuthorMap.copy;
	
	return processedCommitsCount;
}

#pragma mark Properties

- (GTRepository *)repo {
	return self.branch ? self.branch.repository : self.tag.repository;
}

- (NSString *)startSHA {
	if (self.branch) {
		return self.branch.SHA;
	}
	
	NSError *err = nil;
	do {
		id obj = [self.tag objectByPeelingTagError:&err];
		if ([obj isKindOfClass:GTCommit.class]) {
			return ((GTCommit *)obj).SHA;
		}
	} while (!err);
	
	return self.tag.SHA;
}

- (NSDateFormatter *)defaultSectionDateFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.dateFormat = @"EEEE, d MMM, yyyy";
	});
	return formatter;
}

- (NSArray *)authors {
	return self.authorRefs.allKeys;
}

@end
