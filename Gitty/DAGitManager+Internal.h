//
//  DAGitManager+Internal.h
//  Git Code
//
//  Created by Altukhov Anton on 8/17/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DAGitManager.h"

@interface DAGitManager (Internal)
@property (nonatomic, nonatomic, readonly) dispatch_queue_t q;
@end
