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

- (GTSignature *)authorForCommit:(GTCommit *)commit;

@property (strong, nonatomic) NSDateFormatter *dateSectionTitleFormatter;

@property (strong, nonatomic, readonly) NSArray *commits;
// Format: <NSArray of author.email NSStrings> => <GTSignature instance>
@property (strong, nonatomic, readonly) NSArray *authors;
// Format: <NSString author.email> => <GTSignature instance>
@property (strong, nonatomic, readonly) NSDictionary *authorRefs;
// Format: <commits.SHA> => <NSString author.email>
@property (strong, nonatomic, readonly) NSDictionary *commitAuthorMap;

@property (strong, nonatomic, readonly) NSArray *dateSections;
@property (strong, nonatomic, readonly) NSDictionary *commitsOnDateSection;
//@property (strong, nonatomic, readonly) NSDictionary *authorsOnDateSection;
@end
