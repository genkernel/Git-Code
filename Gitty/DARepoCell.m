//
//  DARepoCell.m
//  Gitty
//
//  Created by kernel on 21/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCell.h"

@interface DARepoCell ()
@property (strong, nonatomic, readonly) NSDateFormatter *formatter;
@end

@implementation DARepoCell
@dynamic formatter;

- (void)loadRepo:(NSDictionary *)repo {
	self.nameLabel.text = repo.relativePath;
	
	[self loadLastAccessDate:repo.lastAccessDate];
}

- (void)loadLastAccessDate:(NSDate *)date {
	NSString *dateStr = [self.formatter stringFromDate:date];
	NSArray *strings = @[NSLocalizedString(@"Last access: ", nil), dateStr];
	
	NSArray *attributes = nil;
	{
		NSDictionary *prefix = [NSAttributedString attributesWithTextColor:UIColor.lightGrayColor font:self.dateLabel.font alignment:NSTextAlignmentNatural];
		
		NSDictionary *dateValue = [NSAttributedString attributesWithTextColor:UIColor.darkGrayColor font:self.dateLabel.font alignment:NSTextAlignmentNatural];
		
		attributes = @[prefix, dateValue];
	}
	
	self.dateLabel.attributedText = [NSAttributedString stringByJoiningSimpleStrings:strings applyingAttributes:attributes joinString:nil];
}

#pragma mark Properties
   
- (NSDateFormatter *)formatter {
	   static NSDateFormatter *formatter = nil;
	   static dispatch_once_t onceToken;
	   dispatch_once(&onceToken, ^{
		   formatter = NSDateFormatter.new;
		   formatter.locale = NSLocale.currentLocale;
		   formatter.dateFormat = @"h:mm a, EEEE, d MMM";
	   });
	   return formatter;
   }

@end
