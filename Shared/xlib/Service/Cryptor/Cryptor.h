//
//  Cryptor.h
//  xlib
//
//  Created by kernel on 6/06/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import <Foundation/Foundation.h>

// Cryptor caches calculated hashes so no recalculation is required for known strings.
@interface Cryptor : NSObject
+ (NSString *)md5ForString:(NSString *)str;
+ (NSString *)sha512ForString:(NSString *)str;
@end
