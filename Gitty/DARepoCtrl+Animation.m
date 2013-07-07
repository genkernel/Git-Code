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
		
//		self.commitsContainer.frame = CGRectInset(self.commitsContainer.frame, .0, offset / 2);
	}completion:^(BOOL finished) {
		self.headerContainer.hidden = !visible;
		
		if (!visible) {
			[self.pullingIndicator stopAnimating];
		}
	}];
}

- (void)setStatsHeadlineViewVisible:(BOOL)visible animated:(BOOL)animated {
	if (isStatsHeadlineVisible == visible) {
		return;
	}
	isStatsHeadlineVisible = visible;
	
	CGFloat offset = self.statsHeaderContainer.height;
	offset *= visible ? 1. : -1.;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		self.statsHeaderContainer.y += offset;
		
		CGFloat y = self.statsHeaderContainer.y + self.statsHeaderContainer.height;
		self.commitsContainer.frame = CGRectMake(.0, y, self.view.width, self.view.height - y);
	}];
}

- (void)loadStatsHeadline {
	NSDictionary *opts = @{DTDefaultFontFamily: @"Cochin", DTDefaultFontSize: @15, DTDefaultTextColor: UIColor.whiteColor};
	
	NSString* path = [NSBundle.mainBundle pathForResource:@"StatsHeadline" ofType:@"html"];
	NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	{
		html = [html stringByReplacingOccurrencesOfString:@"%branches%" withString:@"5"];
		html = [html stringByReplacingOccurrencesOfString:@"%commits%" withString:@"15"];
		html = [html stringByReplacingOccurrencesOfString:@"%authors%" withString:@"3"];
	}
	
	NSData *data = [NSData dataWithBytes:html.UTF8String length:html.length];
	
	DTHTMLAttributedStringBuilder *builder = [DTHTMLAttributedStringBuilder.alloc initWithHTML:data options:opts documentAttributes:nil];
	
	self.statsHeadlineLabel.attributedString = builder.generatedAttributedString;
}

@end
