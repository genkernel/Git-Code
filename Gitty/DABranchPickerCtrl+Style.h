//
//  DABranchPickerCtrl+Style.h
//  Gitty
//
//  Created by kernel on 10/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl.h"

@interface DABranchPickerCtrl (Style)
@property (strong, nonatomic, readonly) UIColor *activeTitleColor, *titleColor;

- (void)updateSelectedCellWithRowNumber:(NSInteger)row inTable:(UITableView *)table;
- (void)toggleSelectedCellWithNewIndexPath:(NSIndexPath *)ip inTable:(UITableView *)table;
@end
