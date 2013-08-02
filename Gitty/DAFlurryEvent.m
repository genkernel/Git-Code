//
//  DAFlurryEvent.m
//  Gitty
//
//  Created by kernel on 2/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAFlurryEvent.h"

@implementation DAFlurryEvent

+ (instancetype)eventWithName:(NSString *)name {
	DAFlurryEvent *event = self.new;
	event.name = name;
	
	return event;
}

+ (instancetype)eventWithName:(NSString *)name params:(NSDictionary *)params {
	DAFlurryEvent *event = self.new;
	event.name = name;
	event.params = params;
	
	return event;
}

@end
