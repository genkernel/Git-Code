//
//  System-Constants.h
//  xlib
//
//  Created by Altukhov Anton on 10/1/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#ifndef xlib_System_Constants_h
#define xlib_System_Constants_h

#import <Foundation/Foundation.h>

#define	SECONDS		*1
#define	MINUTES		*60 SECONDS
#define	HOURS		*60 MINUTES
#define	DAYS		*24 HOURS
#define	WEEKS		*7 DAYS

#define	SECONDS_MS	*1000
#define	MINUTES_MS	*60 SECONDS_MS
#define	HOURS_MS	*60 MINUTES_MS
#define	DAYS_MS		*24 HOURS_MS
#define	WEEKS_MS	*7 DAYS_MS

#define POINTERIZE(x) ((__typeof__(x) []){ x })
#define NSVALUE(x) [NSValue valueWithBytes: POINTERIZE(x) objCType: @encode(__typeof__(x))]

#define DEGREES_TO_RADIANS(degrees) degrees * M_PI / 180

#define SuppressPerformSelectorLeakWarning(UserCode) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
UserCode; \
_Pragma("clang diagnostic pop") \
} while (0)

#endif
