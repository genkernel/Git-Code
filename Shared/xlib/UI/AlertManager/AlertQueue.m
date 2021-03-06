//
//  DAAlert.m
//  Gitty
//
//  Created by kernel on 15/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "AlertQueue.h"
#import "Alert+Private.h"


@interface AlertQueue ()
@property (strong, nonatomic, readonly) NSOperationQueue *queue;
@end

@implementation AlertQueue
@dynamic pendingAlertsCount;

+ (instancetype)queue {
	static id instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	
	return instance;
}

- (id)init {
	self = [super init];
	if (self) {
		_queue = NSOperationQueue.new;
		self.queue.maxConcurrentOperationCount = 1;
	}
	return self;
}

- (void)enqueueAlert:(Alert *)alert {
//	alert.alertQueue = self;
	
	[self.queue addOperation:alert];
}

- (NSUInteger)pendingAlertsCount {
	return self.queue.operationCount;
}

@end
