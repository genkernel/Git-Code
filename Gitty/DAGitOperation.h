//
//  DAGitOperation.h
//  Gitty
//
//  Created by kernel on 18/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DAGitOperation <NSObject>
@required
- (void)perform;
@end
