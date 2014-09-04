//
//  DAGitBaseOperation.h
//  Git Code
//
//  Created by Altukhov Anton on 9/4/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DAGitOperation.h"

@interface DAGitBaseOperation : NSObject <DAGitOperation> {
@protected BOOL _hasMoreCommitsToProcess;
}
@end
