//
//  DABranchPickerCtrl+Private.h
//  Gitty
//
//  Created by kernel on 10/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl.h"

@interface DABranchPickerCtrl ()
@property (strong, nonatomic, readonly) NSMutableArray *selectedIndexPaths;
// format: [idx]	=>	<NSArray of concrete items>
@property (strong, nonatomic, readonly) NSMutableArray *filteredItems;

- (void)filterVisibleListWithSearchText:(NSString *)text;
@end
