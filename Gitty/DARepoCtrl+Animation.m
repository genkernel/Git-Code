//
//  DARepoCtrl+Animation.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl+Animation.h"
#import "DARepoCtrl+Private.h"

@implementation DARepoCtrl (Animation)

- (void)setDiffLoadingOverlayVisible:(BOOL)visible animated:(BOOL)animated {
	BOOL isOverlayVisible = !self.diffLoadingOverlay.hidden;
	if (isOverlayVisible == visible) {
		return;
	}
	
	if (visible) {
		self.diffLoadingOverlay.hidden = NO;
		[self.diffLoadingIndicator startAnimating];
	}
	
	void (^actionBlock)() = ^{
		self.diffLoadingOverlay.alpha = visible ? .70 : .0;
	};
	void (^completionBlock)(BOOL) = ^(BOOL finished){
		if (!visible) {
			self.diffLoadingOverlay.hidden = YES;
			[self.diffLoadingIndicator stopAnimating];
		}
	};
	
	if (animated) {
		[UIView animateWithDuration:StandartAnimationDuration animations:actionBlock completion:completionBlock];
	} else {
		actionBlock();
		completionBlock(YES);
	}
}

- (void)setPullingVisible:(BOOL)visible animated:(BOOL)animated {
	if (visible) {
		[self.pullingIndicator startAnimating];
	}
	
	self.pullingContainerTop.constant = visible ? .0 : -self.pullingContainer.height;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		[self.pullingContainer.superview layoutIfNeeded];
	}completion:^(BOOL finished) {
		self.pullingContainer.hidden = !visible;
		
		if (!visible) {
			[self.pullingIndicator stopAnimating];
		}
	}];
}

- (void)setStatsContainerMode:(DAStatsContainerModes)mode animated:(BOOL)animated {
	if (statsContainerMode == mode) {
		return;
	}
	statsContainerMode = mode;
	
	BOOL isStatsShown = DAStatsFullscreenMode == mode;
	
	const CGFloat navBarHeight = self.navigationController.navigationBar.height;
	const CGFloat statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
	const CGFloat topOffset = statusBarHeight + navBarHeight;
	
	// Elements strict DAStatsContainerModes ordering.
	CGFloat offsets[] = {
		navBarHeight + self.grabButton.height,
//		50./*stats header img black part height*/ - self.grabButton.height,
		topOffset - self.grabButton.height,
		self.view.height - self.grabButton.height
	};
	
	CGFloat y = offsets[mode];
	self.mainContainerTop.constant = y;
	
	if (DAStatsFullscreenMode != mode) {
		self.mainContainerHeight.constant = self.view.height - y;
	}
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		[self.mainContainer.superview layoutIfNeeded];
	} completion:^(BOOL finished) {
		self.branchCustomTitleButton.hidden = DAStatsHiddenMode != mode;
		
		if (isStatsShown) {
			self.navigationItem.titleView = nil;
			self.title = NSLocalizedString(@"Stats", nil);
			
			self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.statsCustomRightView];
		} else {
			self.navigationItem.titleView = self.branchCustomTitleContainer;
			self.title = self.currentBranch ? self.currentBranch.shortName : self.currentTag.name;
			
			self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.branchesButton];
		}
		
		self.commitsTable.scrollsToTop = !isStatsShown;
		_statsCtrl.commitsTable.scrollsToTop = isStatsShown;
	}];
	
	NSString *name = DAStatsCtrl.className;
	if (DAStatsFullscreenMode == mode) {
		[DAFlurry logScreenAppear:name];
	} else {
		[DAFlurry logScreenDisappear:name];
	}
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
	if (self.navigationController.navigationBarHidden == hidden) {
		return;
	}
	isNavBarHiddenByThisCtrl = hidden;
	
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
	
	CGFloat offset = self.navigationController.navigationBar.height;
	offset *= hidden ? 1 : -1;
	
	self.mainContainerTop.constant -= offset;
	self.mainContainerHeight.constant += offset;

	[UIView animateWithDuration:LightningAnimationDuration animations:^{
		[self.mainContainer.superview layoutIfNeeded];
	}];
}

@end
