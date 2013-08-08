//
//  DABranchPickerCtrl+Animation.m
//  Gitty
//
//  Created by kernel on 7/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl+Animation.h"

@implementation DABranchPickerCtrl (Animation)

- (void)setListMode:(DAListModes)mode animated:(BOOL)animated {
	if (listMode == mode) {
		return;
	}
	listMode = mode;
	
	BOOL isBranchesTableVisible = DABranchList == listMode;
	CGFloat offset = isBranchesTableVisible ? 0 : -self.branchesTable.superview.width;
	
	self.branchesTableLeft.constant = offset;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		[self.visibleTable.superview layoutIfNeeded];
		
	} completion:^(BOOL finished) {
		self.tagsTable.scrollsToTop = DATagList == listMode;
		self.branchesTable.scrollsToTop = DABranchList == listMode;
	}];
}


@end
