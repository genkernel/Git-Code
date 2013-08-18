//
//  DABranchWalk.h
//  Gitty
//
//  Created by kernel on 18/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAGitOperation.h"

@interface DABranchWalk : NSObject <DAGitOperation>
+ (instancetype)walkForBranch:(GTBranch *)branch;
+ (instancetype)walkForTag:(GTTag *)tag;

@property (strong, nonatomic) NSDateFormatter *dateSectionTitleFormatter;

@property (strong, nonatomic, readonly) NSArray *commits;
@property (strong, nonatomic, readonly) NSMutableDictionary *authors;

@property (strong, nonatomic, readonly) NSArray *dateSections;
@property (strong, nonatomic, readonly) NSDictionary *commitsOnDateSection;
@property (strong, nonatomic, readonly) NSDictionary *authorsOnDateSection;
@end
