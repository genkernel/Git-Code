//
//  DAHunkView.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAHunkContentView.h"

static const NSUInteger AverageSymbolsInLine = 50;
static const CGFloat CodeRightMargin = 10.;

@implementation DAHunkContentView

/*
- (void)awakeFromNib {
	[super awakeFromNib];
	
#ifdef DEBUG
	[self colorizeBorderWithColor:UIColor.greenColor];
#endif
}*/

- (void)loadHunk:(GTDiffHunk *)hunk {
	/*
	__block CGFloat longestLineWidth = .0;
	
	NSUInteger lineCount = hunk.lineCount + 1;//header (function context);
	
	CGFloat lineHeight = self.codeLabel.font.lineHeight;
	CGFloat height = lineCount * lineHeight;
	
	 //omit context header
	CGRect r = CGRectMake(.0, lineHeight, self.width, height);
	UIView *renderImageView = [UIView.alloc initWithFrame:r];
	
	// TODO: Function name context (impl via regexpr).
//	[code appendString:hunk.header];
	
	__block NSUInteger lineOffset = 1;
	
	[hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *line, BOOL *stop) {
		[code appendFormat:@"\n%@", line.content];
		
		CGSize s = CGSizeMake(4096., lineHeight);
		s = [line.content sizeWithFont:self.codeLabel.font constrainedToSize:s lineBreakMode:NSLineBreakByClipping];
		
		longestLineWidth = MAX(longestLineWidth, s.width);
		
		UIView *lineView = [self coloredViewForLine:line];
		lineView.y = lineOffset * self.codeLabel.font.lineHeight;
		[renderImageView addSubview:lineView];
		
		lineOffset++;
	}];
	
	CGSize s = CGSizeMake(longestLineWidth, height);
	s = [code sizeWithFont:self.codeLabel.font constrainedToSize:s lineBreakMode:self.codeLabel.lineBreakMode];
	
	if (s.height != height) {
		[Logger warn:@"Another height calculated."];
		s.height = height;
	}
	
	longestLineWidth += CodeRightMargin;
	s.width += CodeRightMargin;
	
	self.width = s.width;
	self.height = s.height;
	*/
	 
//	self.codeLabel.text = hunk.text;
	
	// render colored background.
//	renderImageView.width = s.width;
//	self.backgroundImage.image = renderImageView.screeshotWithCurrentContext;
	
	CGFloat fontSize = 14;
	UIFont *font = [UIFont fontWithName:@"Courier" size:fontSize];
	
	size_t lineHeight = font.lineHeight;
	
//	assert(lineHeight * hunk.lineCount == self.height);
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[NSObject startMeasurement];
		
//		CGRect r = CGRectMake(.0, .0, self.width, self.height);
//		UIView *renderImageView = [UIView.alloc initWithFrame:r];
		
		UIEdgeInsets insets = UIEdgeInsetsMake(.0, .0, .0, .0);
		
		UIImage *addedImg = [UIImage imageNamed:@"code-green.png"];
		addedImg = [addedImg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
		
		// Optimize with Opaque - YES.
		UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, UIScreen.mainScreen.scale);
		{
			__block NSUInteger lineNumber = 0;
			[hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *line, BOOL *stop) {
				
				UIImage *lineImg = nil;
				if (GTDiffLineOriginAddition == line.origin) {
					lineImg = addedImg;
				} else if (GTDiffLineOriginDeletion == line.origin) {
					lineImg = addedImg;
				} else {
					lineImg = addedImg;
				}
				
				CGFloat y = lineNumber * lineHeight;
				[lineImg drawInRect:CGRectMake(.0, y, self.width, lineHeight)];
				
				[line.content drawAtPoint:CGPointMake(.0, y) withFont:font];
				
				lineNumber++;
			}];
		}
		UIImage *contextImg = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		double period = [NSObject endMeasurement];
		[Logger info:@"Image generated in %.2f", period];
		
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.backgroundImage.image = contextImg;
		});
	});
}

@end
