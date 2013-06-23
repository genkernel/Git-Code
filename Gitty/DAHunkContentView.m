//
//  DAHunkView.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAHunkContentView.h"

static const NSUInteger AverageSymbolsInLine = 50;

@implementation DAHunkContentView

- (void)loadHunk:(GTDiffHunk *)hunk {
#ifdef DEBUG
	[self colorizeBorderWithColor:UIColor.greenColor];
#endif
	
	__block CGFloat longestLineWidth = .0;
	
	CGFloat lineHeight = self.codeLabel.font.lineHeight;
	CGFloat height = hunk.lineCount * lineHeight;
	
	CGRect r = CGRectMake(.0, lineHeight/*omit context header*/, self.width, height);
	UIView *renderImageView = [UIView.alloc initWithFrame:r];
	
	NSUInteger capacity = hunk.lineCount * AverageSymbolsInLine;
	NSMutableString *code = [NSMutableString stringWithCapacity:capacity];
	
	[code appendFormat:@"%@", hunk.header];
	
	__block NSUInteger lineOffset = 1;
	
	[hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *line, BOOL *stop) {
		[code appendFormat:@"\n%@", line.content];
		
		CGSize s = [line.content sizeWithFont:self.codeLabel.font];
		longestLineWidth = MAX(longestLineWidth, s.width + 20.);
		
		UIView *lineView = [self coloredViewForLine:line];
		lineView.y = lineOffset * self.codeLabel.font.lineHeight;
		[renderImageView addSubview:lineView];
		
		lineOffset++;
	}];
	
	CGSize s = CGSizeMake(longestLineWidth, height);
	s = [code sizeWithFont:self.codeLabel.font constrainedToSize:s lineBreakMode:self.codeLabel.lineBreakMode];
	
	if (s.height != height) {
		[Logger warn:@"Another height calculated."];
	}
	
	self.width = s.width;
	self.height = s.height;
	
	self.codeLabel.text = code;
	_longestLineWidth = longestLineWidth;
	
	// render colored background.
	renderImageView.width = s.width;
	self.backgroundImage.image = renderImageView.screeshotWithCurrenetContext;
}

- (UIView *)coloredViewForLine:(GTDiffLine *)line {
	CGRect r = CGRectMake(.0, .0, self.width, self.codeLabel.font.lineHeight);
	UIView *lineView = [UIView.alloc initWithFrame:r];
	lineView.autoresizingMask = UIView.AutoresizingAll;
	
	if (GTDiffLineOriginAddition == line.origin) {
		lineView.backgroundColor = UIColor.codeAdditionColor;
	} else if (GTDiffLineOriginDeletion == line.origin) {
		lineView.backgroundColor = UIColor.codeDeletionColor;
	} else {
		lineView.backgroundColor = UIColor.codeContextColor;
	}
	return lineView;
}

@end
