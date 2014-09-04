//
//  DAGitBaseFilter.h
//  Git Code
//
//  Created by Altukhov Anton on 9/4/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DAGitOperationFilter.h"

@interface DAGitOperationBaseFilter : NSObject <DAGitOperationFilter> {
@protected NSUInteger _processedCommitsCount;
}
@end
