//
//  DAGitFilter.h
//  Gitty
//
//  Created by kernel on 20/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DAGitOperationFilter <NSObject>
//- (BOOL)isValidCommit:(GTCommit *)commit;
- (NSArray *)filterCommits:(NSArray *)list;
@end
