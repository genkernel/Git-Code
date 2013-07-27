//
//  DAStatsCtrl+Animation.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatsCtrl+Animation.h"

@implementation DAStatsCtrl (Animation)

- (void)toggleCommitsTablesAnimated:(BOOL)animated {
	isByBranchTableVisible = !isByBranchTableVisible;
	
	CGFloat offset = isByBranchTableVisible ? -self.commitsTable.superview.width : .0;
	
	self.byAuthorTableLeft.constant = offset;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		[self.commitsTable.superview layoutIfNeeded];
	} completion:^(BOOL finished) {
		self.byAuthorTable.scrollsToTop = !isByBranchTableVisible;
		self.byBranchTable.scrollsToTop = isByBranchTableVisible;
	}];
}

@end
