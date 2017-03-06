//
//  Log.m
//  xlib
//
//  Created by apple on 30/01/12.
//  Copyright (c) 2012 AAV. All rights reserved.
//

#import "LLog.h"
#include <mach/mach_time.h>


NSString *timestamp();

@implementation LLog

+ (void)info:(NSString *)format args:(va_list)args {
	NSString *formattedMessage = [NSString stringWithFormat:@"%@ %@", timestamp(), format];
	
	[self messageWithColor:@"fg155,155,155;" andFormat:formattedMessage vaArgsList:args];
}

// Prepends message with 'INFO' literal.
+ (void)info:(NSString*)format, ... {
	va_list args;
	va_start(args, format);
	
	[self info:format args:args];
	
	va_end(args);
}

// Prepends message with 'ERR' literal.
+ (void)warn:(NSString *)format args:(va_list)args {
	NSString *formattedMessage = [NSString stringWithFormat:@"%@ %@", timestamp(), format];
	
	formattedMessage = [NSString stringWithFormat:@"%@ WARN. %@", timestamp(), format];
	
	[self messageWithColor:@"fg15,155,205;" andFormat:formattedMessage vaArgsList:args];
}

+ (void)warn:(NSString*)format, ... {
	va_list args;
	va_start(args, format);
	
	[self warn:format args:args];
	
	va_end(args);
}

// Prepends message with 'ERR' literal.
+ (void)error:(NSString *)format args:(va_list)args {
	NSString *formattedMessage = [NSString stringWithFormat:@"%@ %@", timestamp(), format];
	
	formattedMessage = [NSString stringWithFormat:@"%@ ERR. %@", timestamp(), format];
	
	[self messageWithColor:@"fg255,15,15;" andFormat:formattedMessage vaArgsList:args];
}

+ (void)error:(NSString*)format, ... {
	va_list args;
	va_start(args, format);
	
	[self error:format args:args];
	
	va_end(args);
}

+ (void)messageWithColor:(NSString *)color andFormat:(NSString *)format vaArgsList:(va_list)args {
#ifdef LOGGER_COLORS
	NSString *msg = [NSString stringWithFormat:@"%@%@ %@ %@", XCODE_COLORS_ESCAPE, color, format, XCODE_COLORS_RESET];
#else
	NSString *msg = format;
#endif
	
	NSLogv(msg, args);
}

@end


#define XCODE_COLORS "XcodeColors"

#define XCODE_COLORS_ESCAPE @"\033["

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

NSString *timestamp() {
	static uint64_t start_time = 0;
    if (start_time == 0) {
        start_time = mach_absolute_time();
	}
    
    static mach_timebase_info_data_t timebase_info = {0,0};
    if (timebase_info.denom == 0) {
        (void) mach_timebase_info(&timebase_info);
	}
    
    uint64_t dt = mach_absolute_time() - start_time;
    double nano = 1e-9 * ( (double) timebase_info.numer) / ((double) timebase_info.denom);
    
    double seconds = ((double) dt) * nano;
    int64_t iseconds = trunc(seconds);
    double milliSeconds = 1000.0f * (seconds - (double)iseconds);
    int64_t imili = trunc(milliSeconds);
    double microSeconds = 1000.0f * (milliSeconds - (double)imili);
    int64_t imicro = trunc(microSeconds);
	
	return [NSString stringWithFormat:@"[%02qu:%03qu:%03qu]", iseconds, imili, imicro];
}
