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
@end

@implementation DABranchWalk
@dynamic repo;

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

- (void)perform {
	NSError *err = nil;
	
	GTEnumerator *iter = [GTEnumerator.alloc initWithRepository:self.repo error:&err];
	
	if (![iter pushSHA:self.startSHA error:&err]) {
		[Logger error:@"Failed to pushSHA to enumarate commits."];
		return;
	}
	
	[iter resetWithOptions:GTEnumeratorOptionsTimeSort];
	
	[NSObject startMeasurement];
	{
		_commits = [iter allObjectsWithError:&err];
	}
	double period = [NSObject endMeasurement];
	[Logger info:@"%d Commits in %@ branch loaded in %.2f.", self.commits.count, self.branch.shortName, period];
	
	[NSObject startMeasurement];
	{
		[self prepareSections];
	}
	period = [NSObject endMeasurement];
	[Logger info:@"Branch statistics gethered in %.2f.", period];
}

- (void)prepareSections {
	_authors = NSMutableDictionary.new;
	
	NSMutableArray *sections = NSMutableArray.new;
	NSMutableDictionary *commitsOnDate = NSMutableDictionary.new;
	NSMutableDictionary *authorsOnDate = NSMutableDictionary.new;
	
	for (GTCommit *commit in self.commits) {
		
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
	}
	
	_dateSections = sections.copy;
	_commitsOnDateSection = commitsOnDate.copy;
	_authorsOnDateSection = authorsOnDate.copy;
}

#pragma mark Properties

- (GTRepository *)repo {
	return self.branch ? self.branch.repository : self.tag.repository;
}

- (NSString *)startSHA {
	return self.branch ? self.branch.SHA : self.tag.SHA;
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

@end
