//
//  NSAttributedString+Gitty.m
//  Gitty
//
//  Created by kernel on 20/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "NSAttributedString+Gitty.h"

@implementation NSAttributedString (Gitty)

+ (NSDictionary *)attributesWithTextColor:(UIColor *)color font:(UIFont *)font alignment:(NSTextAlignment)alignment {
	static NSMutableDictionary *attributes = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		attributes = NSMutableDictionary.new;
	});
	
	attributes[NSFontAttributeName] = font;
	attributes[NSForegroundColorAttributeName] = color;
	
	NSMutableParagraphStyle *paragraph = NSMutableParagraphStyle.new;
	paragraph.alignment = alignment;
	attributes[NSParagraphStyleAttributeName] = paragraph;
	
	return attributes.copy;
}

+ (NSAttributedString *)stringByJoiningSimpleStrings:(NSArray *)strings applyingAttributes:(NSArray *)attributes joinString:(NSString *)join {
	assert(strings.count == attributes.count);
	
	NSMutableAttributedString *result = NSMutableAttributedString.new;
	
	for (NSUInteger i = 0; i < strings.count; i++) {
		NSString *str = strings[i];
		NSDictionary *attr = attributes[i];
		
		if (i > 0 && join) {
			str = [NSString stringWithFormat:@"%@%@", join, str];
		}
		
		NSAttributedString *text = [NSAttributedString.alloc initWithString:str attributes:attr];
		[result appendAttributedString:text];
	}
	
	return result.copy;
}

@end
