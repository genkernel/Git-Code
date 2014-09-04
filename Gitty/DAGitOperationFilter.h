//
//  DAGitFilter.h
//  Gitty
//
//  Created by kernel on 20/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DAGitOperationFilter <NSObject>
@required
- (BOOL)filterNextCommit:(GTCommit *)ci;
- (NSArray *)filterCommits:(NSArray *)list;

//- (BOOL)isValidCommit:(GTCommit *)commit;

@property (nonatomic, readonly) NSUInteger processedCommitsCount;
@end
