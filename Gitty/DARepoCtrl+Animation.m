//
//  DARepoCtrl+Animation.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl+Animation.h"

@implementation DARepoCtrl (Animation)

- (void)setBranchOverlayVisible:(BOOL)visible animated:(BOOL)animated {
	if (isBranchOverlayVisible == visible) {
		return;
	}
	isBranchOverlayVisible = visible;
	
	CGFloat offset = visible ? (self.view.height - self.branchOverlay.height) : self.view.height;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		self.branchOverlay.y = offset;
	}];
}

@end
