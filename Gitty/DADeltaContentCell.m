//
//  DADeltaContentCell.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADeltaContentCell.h"

@implementation DADeltaContentCell

- (void)loadDelta:(GTDiffDelta *)delta {
	__block CGFloat vOffset = .0;
	__block CGFloat longestLineWidth = .0;
	
	[self.scroll removeAllSubviews];
	
	UINib *nib = [UINib nibWithNibName:DAHunkContentView.className bundle:nil];
	
	[delta enumerateHunksWithBlock:^(GTDiffHunk *hunk, BOOL *stop) {
		NSArray *views = [nib instantiateWithOwner:self options:nil];
		DAHunkContentView *view = views[0];
		
		[view loadHunk:hunk];
		
		longestLineWidth = MAX(longestLineWidth, view.longestLineWidth + 10.);
		
		view.y = vOffset;
		
		[self.scroll addSubview:view];
		
		vOffset += view.height + 20.;
	}];
	
	self.scroll.contentSize = CGSizeMake(longestLineWidth, vOffset);
	
	[self.scroll colorizeBorderWithColor:UIColor.blueColor];
}

@end
