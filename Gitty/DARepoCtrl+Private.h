//
//  DARepoCtrl+Private.h
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#ifndef Gitty_DARepoCtrl_Private_h
#define Gitty_DARepoCtrl_Private_h

#import "DAStatsCtrl.h"
#import "DABranchPickerCtrl.h"

@interface DARepoCtrl ()
// Sharing private vars to categories.
@property (strong, nonatomic, readonly) NSArray *remoteBranches, *tags;
@property (strong, nonatomic, readonly) NSDictionary *namedBranches;

@property (strong, nonatomic, readonly) GTTag *currentTag;
@property (strong, nonatomic, readonly) GTBranch *currentBranch;

@property (strong, nonatomic) DACommitCell *reuseCell;
@property (strong, nonatomic) DACommitMessageCell *reuseSimpleCell;

@property (strong, nonatomic) NSIndexPath *selectedCommitIndexPath;

- (void)reloadFilters;
- (void)addBranchesButton;
- (void)presentRevealStatsHint;
- (BOOL)reloadCommitsAndOptionallyTable:(BOOL)shoudReloadTable;
@end

#endif
