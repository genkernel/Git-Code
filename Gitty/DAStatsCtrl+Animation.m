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
	_isByBranchTableVisible = !self.isByBranchTableVisible;
	
	CGFloat offset = self.isByBranchTableVisible ? -self.commitsTable.superview.width : .0;
	
	self.byAuthorTableLeft.constant = offset;
	
	[UIView animateWithDuration:StandardAnimationDuration animations:^{
		[self.commitsTable.superview layoutIfNeeded];
	} completion:^(BOOL finished) {
		self.byAuthorTable.scrollsToTop = !self.isByBranchTableVisible;
		self.byBranchTable.scrollsToTop = self.isByBranchTableVisible;
	}];
	
	NSString *action = self.isByBranchTableVisible ? WorkflowActionByBranchRevealed : WorkflowActionByAuthorRevealed;
	[DAFlurry logWorkflowAction:action];
}

@end
