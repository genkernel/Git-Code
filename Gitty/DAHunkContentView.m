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
	
	size_t width = self.width;
	
	const size_t bytesPerPixel = 4;
	// TODO: Impl retina-quality image:
	// * 2/*@2x image*/;
	NSUInteger capacity = self.width * self.height * bytesPerPixel;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		__block NSUInteger lineNumber = 0;
		
		NSMutableData *data = [NSMutableData dataWithLength:capacity];
		
		[hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *line, BOOL *stop) {
			size_t lineOffset = width * bytesPerPixel * lineNumber;
			void *pixels = &data.mutableBytes[lineOffset];
			
			int color = [self colorCodeForDiffLine:line];
			memset_pattern4(pixels, (const void *)color, width);
			
			lineNumber++;
		}];
		
		UIImage *img = [self createImageFromRawPixelsData:data];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.backgroundImage.image = img;
		});
	});
}

- (int)colorCodeForDiffLine:(GTDiffLine *)line {
	int code = 0;
	char *p = (void *)&code;
	
	p[0] = (char)255;
	p[1] = (char)25;
	p[2] = (char)25;
	p[1] = (char)255;
	
	return code;
}

- (UIImage *)createImageFromRawPixelsData:(NSData *)pixels {
//	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixels.bytes, pixels.length, NULL);
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)pixels);
	
	size_t bytesPerRow = self.width *  4;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
	CGImageRef img = CGImageCreate(self.width, self.height, 8, 32, bytesPerRow, space, bitmapInfo, provider, NULL, false, kCGRenderingIntentDefault);
	
	return [UIImage imageWithCGImage:img];
}

- (UIView *)coloredViewForLine:(GTDiffLine *)line withPixelsWidth:(NSUInteger)width {
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
