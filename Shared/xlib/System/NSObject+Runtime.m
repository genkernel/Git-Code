//
//  NSObject+AAV.m
//  GestureWords
//
//  Created by apple on 1/02/12.
//  Copyright (c) 2012 AAV. All rights reserved.
//

#import "NSObject+Runtime.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <mach/mach_time.h>

NSString *isFinishedKeyPath = @"isFinished";
NSString *isExecutingKeyPath = @"isExecuting";

@implementation NSObject (Runtime)

- (NSString *)className {
	return [NSStringFromClass(self.class) componentsSeparatedByString:@"."].lastObject;
}

+ (NSString *)className {
	return [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
}

- (NSString *)moduleClassName {
	return NSStringFromClass(self.class);
}

+ (NSString *)moduleClassName {
	return NSStringFromClass(self);
}

- (NSDictionary *)propertiesDict {
    NSMutableDictionary *dict = @{}.mutableCopy;
	
    unsigned count = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &count);
	
    for (int i = 0; i < count; i++) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
		
		id value = [self valueForKey:propertyName];
		if (value) {
			[dict setObject:value forKey:propertyName];
		}
    }
	
    free(properties);
	
    return dict.copy;
}

- (NSDictionary *)propertiesDictWithKeys:(NSArray *)keys {
	//
	// TODO: - dictionaryWithValuesForKeys:
	// Simply delegate this call to dictionaryWithValuesForKeys: native method.
	//
	// But current implementation diggs superclass properties also.
	//
	
	NSMutableDictionary *dict = @{}.mutableCopy;
	
	Class cls = self.class;
	
	while (cls != NSObject.class) {
		unsigned count = 0;
		objc_property_t *properties = class_copyPropertyList(cls, &count);
		
		for (int i = 0; i < count; i++) {
			NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
			
			if (![keys containsObject:propertyName]) {
				continue;
			}
			
			id value = [self valueForKey:propertyName];
			if (value) {
				[dict setObject:value forKey:propertyName];
			}
		}
		
		free(properties);
		
		cls = class_getSuperclass(cls);
	}
	
    return dict.copy;
}

+ (void)replaceInstanceMethod:(SEL)originalMethod withMethod:(SEL)customMethod {
	Method method1 = class_getInstanceMethod(self.class, originalMethod);
	Method method2 = class_getInstanceMethod(self.class, customMethod);
	
    method_exchangeImplementations(method1, method2);
}

+ (void)replaceClassMethod:(SEL)originalMethod withMethod:(SEL)customMethod {
	Method method1 = class_getClassMethod(self.class, originalMethod);
	Method method2 = class_getClassMethod(self.class, customMethod);
	
    method_exchangeImplementations(method1, method2);
}

+ (void)replaceClassMethod:(SEL)method withBlock:(id)block {
    Method originalMethod = class_getClassMethod(self.class, method);
    IMP implementation = imp_implementationWithBlock(block);
	
    class_replaceMethod(objc_getMetaClass(self.className.UTF8String), method, implementation, method_getTypeEncoding(originalMethod));
}

+ (void)replaceInstanceMethod:(SEL)method withBlock:(id)block {
    Method originalMethod = class_getInstanceMethod(self.class, method);
    IMP implementation = imp_implementationWithBlock(block);
	
	//	class_replace
    class_replaceMethod(objc_getMetaClass(self.className.UTF8String), method, implementation, method_getTypeEncoding(originalMethod));
}

static uint64_t measurementStart;

+ (void)startMeasurement {
//#ifndef DEBUG
//	[LLog warn:@"Measuring speed in Release mode."];
//#endif
	
	measurementStart = mach_absolute_time();
}

+ (double)endMeasurement {
	mach_timebase_info_data_t info;
	mach_timebase_info(&info);
	
	uint64_t dt = mach_absolute_time() - measurementStart;
    double nano = 1e-9 * ((double)info.numer) / ((double)info.denom);
	return ((double)dt) * nano;
}

@end

