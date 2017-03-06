//
//  NSString+Helper.h
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)
- (NSString *)concat:(NSString *)addition;
- (NSString *)concatPath:(NSString *)path;
- (NSString *)concatExt:(NSString *)extention;

- (NSString *)encodedString;
- (NSString *)decodedString;

- (BOOL)isValidIPAddress;
@end
