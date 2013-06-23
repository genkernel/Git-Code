//
//  DAGravatar.h
//  Gitty
//
//  Created by kernel on 24/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "Cryptor.h"
#import "UIImageView+Gravatar.h"

@interface DAGravatar : NSObject
+ (instancetype)manager;

- (NSURL *)getUrlForEmail:(NSString *)email;
@end
