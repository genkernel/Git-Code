//
//  NSString+Helper.h
//  Gitty
//
//  Created by kernel on 17/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Gitty)
- (BOOL)isUrlSuitable;
- (BOOL)isServerNameSuitable;
@end
