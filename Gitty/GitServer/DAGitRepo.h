//
//  DAGitRepo.h
//  Gitty
//
//  Created by kernel on 21/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DynamicObject.h"

@interface DAGitRepo : DynamicObject
@property (strong, nonatomic, readonly) NSString *relativePath;
@property (strong, nonatomic) NSDate *lastAccessDate;
@end
