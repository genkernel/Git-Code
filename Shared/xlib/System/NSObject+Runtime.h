//
//  NSObject+AAV.h
//  GestureWords
//
//  Created by apple on 1/02/12.
//  Copyright (c) 2012 AAV. All rights reserved.
//

#import "LLog.h"

#ifndef NSObjectRuntime
#define NSObjectRuntime

extern NSString *isExecutingKeyPath;
extern NSString *isFinishedKeyPath;

@interface NSObject (Runtime)
- (NSString *)className;
+ (NSString *)className;

- (NSString *)moduleClassName;
+ (NSString *)moduleClassName;

- (NSDictionary *)propertiesDict;
// SEE: use dictionaryWithValuesForKeys: native method
- (NSDictionary *)propertiesDictWithKeys:(NSArray *)keys;

+ (void)replaceClassMethod:(SEL)method withBlock:(id)block;
+ (void)replaceInstanceMethod:(SEL)method withBlock:(id)block;

+ (void)replaceClassMethod:(SEL)originalMethod withMethod:(SEL)customMethod;
+ (void)replaceInstanceMethod:(SEL)originalMethod withMethod:(SEL)customMethod;

//#ifdef DEBUG
+ (void)startMeasurement;
+ (double)endMeasurement;
//#endif
@end


#endif
