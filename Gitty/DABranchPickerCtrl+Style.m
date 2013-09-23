//
//  DABranchPickerCtrl+Style.m
//  Gitty
//
//  Created by kernel on 10/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl+Style.h"
#import "DABranchPickerCtrl+Private.h"

@implementation DABranchPickerCtrl (Style)
@dynamic activeTitleColor, titleColor;

- (UIColor *)activeTitleColor {
	return UIColor.acceptingBlueColor;
}

- (UIColor *)titleColor {
	return UIColor.blackColor;
}

#pragma mark TableView Helper

- (void)updateSelectedCellWithRowNumber:(NSInteger)row inTable:(UITableView *)table {
	NSInteger rowsCount = [table numberOfRowsInSection:0];
	if (row >= rowsCount) {
		return;
	}
	
	NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
	[self toggleSelectedCellWithNewIndexPath:ip inTable:table];
}

- (void)toggleSelectedCellWithNewIndexPath:(NSIndexPath *)ip inTable:(UITableView *)table {
	NSIndexPath *previousIndexPath = self.selectedIndexPaths[table.tag];
	if (2 == previousIndexPath.length) {
		[self deselectCellAtIndexPath:previousIndexPath table:table];
	}
	
	self.selectedIndexPaths[table.tag] = ip;
	[self selectCellAtIndexPath:ip table:table];
}

- (void)deselectCellAtIndexPath:(NSIndexPath *)ip table:(UITableView *)table {
	UITableViewCell *cell = [table cellForRowAtIndexPath:ip];
	cell.textLabel.textColor = self.titleColor;
}

- (void)selectCellAtIndexPath:(NSIndexPath *)ip table:(UITableView *)table {
	UITableViewCell *cell = [table cellForRowAtIndexPath:ip];
	cell.textLabel.textColor = self.activeTitleColor;
}

@end
