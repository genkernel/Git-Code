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
		
//#ifdef DEBUG
//		[self.scroll colorizeBorderWithColor:UIColor.blueColor];
//#endif
	}
	return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	// TODO: Dont remove and reuse subviews properly.
	// (Eliminate UINib::instantiateWithOwner: calls)
	[self.scroll removeAllSubviews];
	
	self.scroll.contentOffset = CGPointZero;
}

- (void)loadDelta:(GTDiffDelta *)delta {
	__block CGFloat vOffset = .0;
	__block CGFloat longestLineWidth = .0;
	
	// TODO: fetch font directly from corresponding view.
	UIFont *font = [UIFont fontWithName:@"Courier" size:14.];
	NSLineBreakMode lineBreakMode = NSLineBreakByClipping;
	
	UINib *nib = [UINib nibWithNibName:DAHunkContentView.className bundle:nil];
	
	for (GTDiffHunk *hunk in delta.hunks) {
		NSArray *views = [nib instantiateWithOwner:self options:nil];
		DAHunkContentView *view = views[0];
		
		CGSize s = CGSizeMake(4096., font.lineHeight);
		s = [hunk.longestLine.content sizeWithFont:font constrainedToSize:s lineBreakMode:lineBreakMode];
		
		CGFloat height = (hunk.lineCount + 1) * font.lineHeight;
		
		view.frame = CGRectMake(.0, vOffset, s.width, height);
		
		[view loadHunk:hunk];
		
		[self.scroll addSubview:view];
		
		vOffset += height;
		longestLineWidth = MAX(longestLineWidth, s.width);
	};
	
	for (UIView *v in self.scroll.subviews) {
		v.width = longestLineWidth;
	}
	
	self.scroll.contentSize = CGSizeMake(longestLineWidth, vOffset);
}

@end
