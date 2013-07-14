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
	
	CGFloat offset = self.branchCtrlContainer.width;
	offset *= visible ? -1. : 1.;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		self.branchOverlay.x += offset;
	}];
}

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

- (void)setPullingViewVisible:(BOOL)visible animated:(BOOL)animated {
	if (visible) {
		[self.pullingIndicator startAnimating];
	}
	
	CGFloat offset = self.headerContainer.height;
	offset *= visible ? 1. : -1.;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		self.headerContainer.y += offset;
	}completion:^(BOOL finished) {
		self.headerContainer.hidden = !visible;
		
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
	
	// Elements strict DAStatsContainerModes ordering.
	CGFloat offsets[] = {
		_statsCtrl.headlineLabel.height,
		.0,
		self.view.height - (self.grabButton.height - 30./*Out-of-bounds part of image*/)
	};
	
	CGFloat y = offsets[mode];
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		CGRect r = CGRectMake(.0, y, self.view.width, self.view.height);
		self.mainContainer.frame = r;
	} completion:^(BOOL finished) {
		BOOL isStatsShown = DAStatsFullscreenMode == mode;
		
		self.title = isStatsShown ? NSLocalizedString(@"Yesterday", nil) : _currentBranch.shortName;
		
		self.statsModeSelector.hidden = !isStatsShown;
		self.forgetButton.hidden = isStatsShown;
		
		{
			self.statsTitleWeekdayLabel.text = _statsCustomTitle;
			self.statsTitleWeekendHintLabel.text = _statsCustomHint;
			self.navigationItem.titleView = isStatsShown ? self.weekendTitleView : nil;
		}
		
		self.commitsTable.scrollsToTop = !isStatsShown;
		_statsCtrl.commitsTable.scrollsToTop = isStatsShown;
	}];
}

- (void)loadStatsHeadline {
	UIFont *font = _statsCtrl.headlineLabel.font;
	
	// Unique number string - space delimeter at the end.
	NSString *branchesCount = [NSString stringWithFormat:@"%d ", _statsCommitsByBranch.count];
	// String uniqueness - 2 spaces.
	NSString *commitsCount = [NSString stringWithFormat:@" %d ", _statsCommitsCount];
	// String uniqueness - leading space delimeter.
	NSString *authorsCount = [NSString stringWithFormat:@" %d", _statsCommitsByAuthor.count];
	
	NSString *branchesLiteral = _statsCommitsByBranch.count > 1 ? @"Branches updated with" : @"Branch updated with";
	NSString *commitsLiteral = _statsCommitsCount > 1 ? @"Commits by\n" : @"Commit by\n";
	NSString *authorsLiteral = _statsCommitsByAuthor.count > 1 ? @" Authors recently." : @" Author recently.";
	
	NSArray *keys = @[branchesCount, branchesLiteral, commitsCount, commitsLiteral, authorsCount, authorsLiteral];
	
	NSDictionary *info = @{keys[0]: @{NSForegroundColorAttributeName: UIColor.acceptingGreenColor, NSFontAttributeName: font},
						keys[1]: @{NSForegroundColorAttributeName: UIColor.whiteColor, NSFontAttributeName: font},
						keys[2]: @{NSForegroundColorAttributeName: UIColor.acceptingBlueColor, NSFontAttributeName: font},
						keys[3]: @{NSForegroundColorAttributeName: UIColor.whiteColor, NSFontAttributeName: font},
						keys[4]: @{NSForegroundColorAttributeName: UIColor.cancelingRedColor, NSFontAttributeName: font},
						keys[5]: @{NSForegroundColorAttributeName: UIColor.whiteColor, NSFontAttributeName: font}};
	
	NSMutableAttributedString *desc = NSMutableAttributedString.new;
	
	for (NSString *text in keys) {
		NSDictionary *opts = info[text];
		
		NSAttributedString *str = [NSAttributedString.alloc initWithString:text attributes:opts];
		[desc appendAttributedString:str];
	}
	
	_statsCtrl.headlineLabel.attributedText = desc;
}

@end
