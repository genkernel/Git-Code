//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DynamicObject.h"
#import <objc/runtime.h>

@interface DynamicObject ()
@property (strong, nonatomic) NSMutableDictionary *storage;
@end

@implementation DynamicObject
@synthesize storage = _storage;

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.storage forKey:@"storage"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_storage = [coder decodeObjectForKey:@"storage"];
	}
	return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _storage = NSMutableDictionary.new;
    }
    return self;
}

+ (instancetype)storageWithInitialProperties:(NSDictionary *)dict {
	DynamicObject *obj = self.new;
	obj.storage = [NSMutableDictionary dictionaryWithDictionary:dict];
	
	return obj;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    const char *rawName = sel_getName(sel);
    NSString *name = NSStringFromSelector(sel);
    
    NSString *propertyName = nil;
    
    if ([name hasPrefix:@"set"]) {
        propertyName = [NSString stringWithFormat:@"%c%s", tolower(rawName[3]), (rawName+4)];
    } else if ([name hasPrefix:@"is"]) {
        propertyName = [NSString stringWithFormat:@"%c%s", tolower(rawName[2]), (rawName+3)];
    } else {
        propertyName = name;
    }
    propertyName = [propertyName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    Class cls = [self class];
    objc_property_t property = class_getProperty(cls, [propertyName UTF8String]);
    
    if (property == NULL) {
		// Sel points to silly method and not our dynamic property.
		return [super resolveInstanceMethod:sel];
    }
    
    const char *rawPropertyName = property_getName(property);
    propertyName = [NSString stringWithUTF8String:rawPropertyName];
    
    NSString *getterName = nil;
    NSString *setterName = nil;
    NSString *propertyType = nil;
    BOOL isReadonly = NO, isDynamic = NO;
    BOOL isAtomic = YES;
    
    NSString *propertyInfo = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSArray *propertyAttributes = [propertyInfo componentsSeparatedByString:@","];
    for (NSString *attribute in propertyAttributes) {
        if ([attribute hasPrefix:@"G"] && getterName == nil) {
            getterName = [attribute substringFromIndex:1];
        } else if ([attribute hasPrefix:@"S"] && setterName == nil) {
            setterName = [attribute substringFromIndex:1];
        } else if ([attribute hasPrefix:@"t"] && propertyType == nil) {
            propertyType = [attribute substringFromIndex:1];
        } else if ([attribute isEqualToString:@"N"]) {
            isAtomic = NO;
        } else if ([attribute isEqualToString:@"R"]) {
            isReadonly = YES;
        } else if ([attribute isEqualToString:@"D"]) {
            isDynamic = YES;
        }
    }
    
    if (isAtomic) {
        NSLog(@"unable to generate truly atomic accessors for \"%@.%@\".  Sorry!", NSStringFromClass(cls), propertyName);
    }
    
    if (getterName == nil) {
        getterName = propertyName;
    }
    if (setterName == nil) {
		if (1 == propertyName.length) {
			setterName = [NSString stringWithFormat:@"set%c:", toupper(rawPropertyName[0])];
		} else {
			setterName = [NSString stringWithFormat:@"set%c%@:", toupper(rawPropertyName[0]),
						  [NSString stringWithUTF8String:&rawPropertyName[1]]];
		}
    }
    
    id(^getterBlock)(id) = ^id(id _s) {
		return [[_s storage] objectForKey:propertyName];
    };
    void(^setterBlock)(id,id) = ^(id _s, id _v) {
		if (!_v) {
			[LLog error:@"%s", __PRETTY_FUNCTION__];
			return;
		}
		[[_s storage] setObject:_v forKey:propertyName];
    };
    
    IMP getterIMP = imp_implementationWithBlock(getterBlock);
    IMP setterIMP = imp_implementationWithBlock(setterBlock);
    
    BOOL getterAdded = NO;
    BOOL setterAdded = NO;
    
    if (isDynamic || getterIMP != NULL) {
        getterAdded = class_addMethod(cls, NSSelectorFromString(getterName), getterIMP, "@@:");
    }
        
    if (isDynamic || isReadonly == NO) {
        if (isDynamic || setterIMP != NULL) {
            setterAdded = class_addMethod(cls, NSSelectorFromString(setterName), setterIMP, "v@:@");
        }
    } else {
        imp_removeBlock(setterIMP);
        setterAdded = YES;
    }
    
	return getterAdded && setterAdded;
}

@end
