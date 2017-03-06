//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LLog.h"

@interface DynamicObject : NSObject {
	@protected NSMutableDictionary *_storage;
}
+ (instancetype)storageWithInitialProperties:(NSDictionary *)dict;
@end
