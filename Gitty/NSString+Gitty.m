//
//  NSString+Helper.m
//  Gitty
//
//  Created by kernel on 17/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "NSString+Gitty.h"

@implementation NSString (Gitty)

- (BOOL)isUrlSuitable {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9a-zA-Z/-/.]*"];
	return [predicate evaluateWithObject:self];
}

- (BOOL)isServerNameSuitable {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9a-zA-Z-]*"];
	return [predicate evaluateWithObject:self];
}

@end
