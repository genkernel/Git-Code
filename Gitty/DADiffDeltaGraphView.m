//
//  DADiffDeltaGraphView.m
//  Gitty
//
//  Created by kernel on 8/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADiffDeltaGraphView.h"

static const NSUInteger DefaultSquaresNumber = 5;
static const CGFloat DefaultSquaresMargin = 3.;

@implementation DADiffDeltaGraphView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self setupView];
    }
    return self;
}

- (void)setupView {
	self.layer.borderWidth = 1.;
	self.layer.borderColor = UIColor.lightGrayColor.CGColor;
	
	self.layer.cornerRadius = 2.;
	
	_squaresNumber = DefaultSquaresNumber;
	_squaresMargin = DefaultSquaresMargin;
}

- (void)reloadSubviewWithDelta:(GTDiffDelta *)delta {
	[self removeAllSubviews];
	
	UIColor *additionSquareColor = [UIColor colorWithRed:51./255. green:204./255. blue:102./255. alpha:1.];
	UIColor *deletionSquareColor = [UIColor colorWithRed:1. green:51./255. blue:51./255. alpha:1.];
	UIColor *neutralSquareColor = [UIColor colorWithRed:155./255. green:155./255. blue:155./255. alpha:1.];
	
	NSUInteger count = self.squaresNumber;
	
	
	NSUInteger additionSquaresCount = 0, deletionSquaresCount = 0;
	NSUInteger totalChangesCount = delta.addedLinesCount + delta.deletedLinesCount;
	if (totalChangesCount > 0) {
		additionSquaresCount = delta.addedLinesCount * count / totalChangesCount;
		deletionSquaresCount = delta.deletedLinesCount * count / totalChangesCount;
	} else {
		[Logger error:@"Zero total changed in Diff Delta specified."];
	}
	
	const CGFloat widthForAllSquares = self.width -  (self.squaresMargin * (self.squaresNumber + 1));
	const CGFloat squareWidth = floorf(widthForAllSquares / self.squaresNumber);
	
	NSUInteger added = 0, deleted = 0;
	
	for (NSUInteger i = 0; i < self.squaresNumber; i++) {
		UIColor *color = neutralSquareColor;
		if (added < additionSquaresCount) {
			added++;
			color = additionSquareColor;
		} else if (deleted < deletionSquaresCount) {
			deleted++;
			color = deletionSquareColor;
		}
		
		CGFloat x = i * (self.squaresMargin + squareWidth) + self.squaresMargin;
		CGRect r = CGRectMake(x, self.squaresMargin, squareWidth, squareWidth);
		
		UIView *square = [UIView.alloc initWithFrame:r];
		square.backgroundColor = color;
		
		[self addSubview:square];
	}
}

#pragma mark Properties

- (void)setDelta:(GTDiffDelta *)delta {
	if (delta == _delta) {
		return;
	}
	
	_delta = delta;
	
	[self reloadSubviewWithDelta:delta];
}

@end
