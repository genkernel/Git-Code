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

- (void)setPullingViewVisible:(BOOL)visible animated:(BOOL)animated {
	if (visible) {
		[self.pullingIndicator startAnimating];
	}
	
	CGFloat offset = self.headerContainer.height;
	offset *= visible ? 1. : -1.;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		self.headerContainer.y += offset;
		
		self.commitsContainer.frame = CGRectInset(self.commitsContainer.frame, .0, offset / 2);
	}completion:^(BOOL finished) {
		self.headerContainer.hidden = !visible;
		
		if (!visible) {
			[self.pullingIndicator stopAnimating];
		}
	}];
}

- (void)setFiltersViewVisible:(BOOL)visible animated:(BOOL)animated {
	CGFloat offset =  self.innerFiltersContainer.height;
	offset *= visible ? -1. : 1.;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		self.filtersContainer.y += offset;
	}completion:^(BOOL finished) {
		if (visible) {
			self.grayOverlay.hidden = NO;
		}
		
		[UIView animateWithDuration:SmoothAnimationDuration animations:^{
			self.grayOverlay.alpha = visible ? .5 : .0;
		}completion:^(BOOL finished) {
			if (!visible) {
				self.grayOverlay.hidden = YES;
			}
		}];
	}];
}

@end
