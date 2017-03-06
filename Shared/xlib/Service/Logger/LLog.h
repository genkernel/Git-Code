//
//  Log.h
//  xlib
//
//  Created by apple on 30/01/12.
//  Copyright (c) 2012 AAV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLog : NSObject
+ (void)info:(NSString*)format, ...;
+ (void)warn:(NSString*)format, ...;
+ (void)error:(NSString*)format, ...;

+ (void)info:(NSString *)format args:(va_list)args;
+ (void)warn:(NSString *)format args:(va_list)args;
+ (void)error:(NSString *)format args:(va_list)args;
@end

