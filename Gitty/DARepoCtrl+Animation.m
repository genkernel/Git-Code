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

- (void)setBranchOverlayVisible:(BOOL)visible animated:(BOOL)animated {
	if (isBranchOverlayVisible == visible) {
		return;
	}
	isBranchOverlayVisible = visible;
	
	CGFloat offset = self.branchCtrlContainer.width;
	offset *= visible ? -1. : 1.;
	
	self.branchOverlayLeft.constant += offset;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		[self.branchOverlay.superview layoutIfNeeded];
		
		self.commitsTable.scrollsToTop = !visible;
		self.branchPickerCtrl.mainTable.scrollsToTop = visible;
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
	
	// Elements strict DAStatsContainerModes ordering.
	CGFloat offsets[] = {
		50./*stats header img black part height*/ - self.grabButton.height,
		-self.grabButton.height,
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
		BOOL isStatsShown = DAStatsFullscreenMode == mode;
		
		self.branchCustomTitleButton.hidden = DAStatsHiddenMode != mode;
		
		if (isStatsShown) {
			self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.statsCustomRightView];
		} else {
			self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.forgetButton];
		}
		
		{
			self.statsTitleWeekdayLabel.text = _statsCustomTitle;
			self.statsTitleWeekendHintLabel.text = _statsCustomHint;
			self.navigationItem.titleView = isStatsShown ? self.weekendTitleView : self.branchCustomTitleContainer;
		}
		
		self.commitsTable.scrollsToTop = !isStatsShown;
		_statsCtrl.commitsTable.scrollsToTop = isStatsShown;
	}];
}

- (void)resetStatsHeadline {
	_statsCtrl.headlineLabel.attributedText = NSAttributedString.new;
}

- (void)loadStatsHeadline {
	// Unique number string - space delimeter at the end.
	NSString *branchesCount = [NSString stringWithFormat:@"%d ", _statsCommitsByBranch.count];
	// String uniqueness - 2 spaces.
	NSString *commitsCount = [NSString stringWithFormat:@" %d ", _statsCommitsCount];
	// String uniqueness - leading space delimeter.
	NSString *authorsCount = [NSString stringWithFormat:@" %d", _statsCommitsByAuthor.count];
	
	NSString *branchesLiteral = _statsCommitsByBranch.count > 1 ? @"Branches updated with" : @"Branch updated with";
	NSString *commitsLiteral = _statsCommitsCount > 1 ? @"Commits\nby" : @"Commit\nby";
	NSString *authorsLiteral = _statsCommitsByAuthor.count > 1 ? @" Authors recently." : @" Author recently.";
	
	NSArray *strings = @[branchesCount, branchesLiteral, commitsCount, commitsLiteral, authorsCount, authorsLiteral];
	
	NSArray *attributes = @[
							[self attributesWithForegroundColor:UIColor.acceptingGreenColor],
							[self attributesWithForegroundColor:UIColor.whiteColor],
							[self attributesWithForegroundColor:UIColor.acceptingBlueColor],
							[self attributesWithForegroundColor:UIColor.whiteColor],
							[self attributesWithForegroundColor:UIColor.cancelingRedColor],
							[self attributesWithForegroundColor:UIColor.whiteColor]];
	
	_statsCtrl.headlineLabel.attributedText = [NSAttributedString stringByJoiningSimpleStrings:strings applyingAttributes:attributes joinString:nil];
}

- (NSDictionary *)attributesWithForegroundColor:(UIColor *)color {
	static NSMutableDictionary *attributes = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableParagraphStyle *paragraph = NSMutableParagraphStyle.new;
		paragraph.alignment = NSTextAlignmentCenter;
		
		attributes = NSMutableDictionary.new;
		attributes[NSFontAttributeName] = _statsCtrl.headlineLabel.font;
		attributes[NSParagraphStyleAttributeName] = paragraph;
	});
	
	attributes[NSForegroundColorAttributeName] = color;
	return attributes.copy;
}

@end
