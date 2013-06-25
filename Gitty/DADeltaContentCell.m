//
//  DADeltaContentCell.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADeltaContentCell.h"

@implementation DADeltaContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		NSArray *views = [NSBundle.mainBundle loadNibNamed:self.className owner:self options:nil];
		UIView *view = views[0];
		
		if (view.height != self.contentView.height) {
			[Logger error:@"%@.scroll.height != cell.contentView.height", self.className];
			view.height = self.contentView.height;
		}
		
		[self.contentView addSubview:view];
	}
	return self;
}

- (void)loadDelta:(GTDiffDelta *)delta {
	__block CGFloat vOffset = .0;
	__block CGFloat longestLineWidth = .0;
	
	[self.scroll removeAllSubviews];
	
	UINib *nib = [UINib nibWithNibName:DAHunkContentView.className bundle:nil];
	
	[delta enumerateHunksWithBlock:^(GTDiffHunk *hunk, BOOL *stop) {
		NSArray *views = [nib instantiateWithOwner:self options:nil];
		DAHunkContentView *view = views[0];
		
		[view loadHunk:hunk];
		
		longestLineWidth = MAX(longestLineWidth, view.longestLineWidth);
		
		view.y = vOffset;
		
		[self.scroll addSubview:view];
		
		vOffset += view.height;
	}];
	
	self.scroll.contentSize = CGSizeMake(longestLineWidth, vOffset);
	
#ifdef DEBUG
	[self.scroll colorizeBorderWithColor:UIColor.blueColor];
#endif
}

@end
