//
//  DACommitCell.m
//  Gitty
//
//  Created by kernel on 4/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DACommitCell.h"

@interface DACommitCell ()
@property (strong, nonatomic, readonly) NSDateFormatter *dateFormatter;
@end

@implementation DACommitCell
@dynamic dateFormatter;

- (void)loadCommit:(GTCommit *)commit {
	self.shortShaLabel.text = [NSString stringWithFormat:@"#%@", commit.shortSha];
	
	self.committerLabel.hidden = commit.author == commit.committer;
	self.committerLabel.text = [NSString stringWithFormat:@"by %@<%@>", commit.committer.name, commit.committer.email];
	
	NSString *date = [self.dateFormatter stringFromDate:commit.commitDate];
	self.dateLabel.text = [NSString stringWithFormat:@"on %@", date];
	
	self.authorLabel.text = [NSString stringWithFormat:@"%@<%@>", commit.author.name, commit.author.email];
	
	self.commitLabel.text = [NSString stringWithFormat:@"%@", commit.messageSummary];
}

#pragma mark Properties

- (NSDateFormatter *)dateFormatter {
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = NSDateFormatter.new;
		formatter.locale = NSLocale.currentLocale;
		formatter.dateFormat = @"HH:mm dd/MM/yy";
	});
	return formatter;
}

@end
