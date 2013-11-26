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

@interface DAHunkContentView ()
@property (strong, nonatomic, readonly) UIImage *addedImg, *deletedImg, *neutralImg;
@end

@implementation DAHunkContentView
@dynamic addedImg, deletedImg, neutralImg;

/*
- (void)awakeFromNib {
	[super awakeFromNib];
	
#ifdef DEBUG
	[self colorizeBorderWithColor:UIColor.greenColor];
#endif
}*/

- (NSDictionary *)attributesWithFont:(UIFont *)font {
	NSMutableDictionary *attributes = @{}.mutableCopy;
	
	attributes[NSFontAttributeName] = font;
//	attributes[NSForegroundColorAttributeName] = color;
	
	return attributes;
}

- (void)loadHunk:(GTDiffHunk *)hunk {
	CGFloat fontSize = 14;
	UIFont *font = [UIFont fontWithName:@"Courier" size:fontSize];
	
	UIImage *noNewLineImg = [UIImage imageNamed:@"nonewline.png"];
	
	size_t lineHeight = font.lineHeight;
	
//	assert(lineHeight * hunk.lineCount == self.height);
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		NSDictionary *attributes = [self attributesWithFont:font];
		
		[NSObject startMeasurement];
		
		UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, UIScreen.mainScreen.scale);
		{
			__block NSUInteger lineNumber = 0;
			
			// header (function context line).
			[self.neutralImg drawInRect:CGRectMake(.0, .0, self.width, lineHeight)];
			lineNumber++;
			
			// @testme
			NSError *err = nil;
			[hunk enumerateLinesInHunk:&err usingBlock:^(GTDiffLine *line, BOOL *stop) {
				UIImage *lineImg = [self coloredBackgroundImageForLine:line];
				
				CGFloat y = lineNumber * lineHeight;
				[lineImg drawInRect:CGRectMake(.0, y, self.width, lineHeight)];
				
				BOOL isEOFNewLineStuff = GTDiffLineOriginDeleteEOFNewLine == line.origin || GTDiffLineOriginAddEOFNewLine == line.origin || GTDiffLineOriginNoEOFNewlineContext == line.origin;
				if (isEOFNewLineStuff) {
					[noNewLineImg drawAtPoint:CGPointMake(.0, y)];
				} else {
//					[line.content drawAtPoint:CGPointMake(.0, y) withFont:font];
					[line.content drawAtPoint:CGPointMake(.0, y) withAttributes:attributes];
				}
				
				lineNumber++;
			}];
			
			if (err) {
				[Logger error:@"%@", err];
			}
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

- (UIImage *)coloredBackgroundImageForLine:(GTDiffLine *)line {
	if (GTDiffLineOriginAddition == line.origin) {
		return self.addedImg;
	} else if (GTDiffLineOriginDeletion == line.origin) {
		return self.deletedImg;
	} else {
		return self.neutralImg;
	}
}

#pragma mark Properties

- (UIImage *)addedImg {
	static UIImage *img = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIEdgeInsets insets = UIEdgeInsetsZero;
		
		img = [UIImage imageNamed:@"code-green.png"];
		img = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
	});
	return img;
}

- (UIImage *)deletedImg {
	static UIImage *img = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIEdgeInsets insets = UIEdgeInsetsMake(.0, .0, .0, .0);
		
		img = [UIImage imageNamed:@"code-red.png"];
		img = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
	});
	return img;
}

- (UIImage *)neutralImg {
	static UIImage *img = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIEdgeInsets insets = UIEdgeInsetsMake(.0, .0, .0, .0);
		
		img = [UIImage imageNamed:@"code-ctx.png"];
		img = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
	});
	return img;
}

@end
