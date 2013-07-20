//
//  NSAttributedString+Gitty.h
//  Gitty
//
//  Created by kernel on 20/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Gitty)
+ (NSDictionary *)attributesWithTextColor:(UIColor *)color font:(UIFont *)font alignment:(NSTextAlignment)alignment;
+ (NSAttributedString *)stringByJoiningSimpleStrings:(NSArray *)strings applyingAttributes:(NSArray *)attributes joinString:(NSString *)join;
@end
