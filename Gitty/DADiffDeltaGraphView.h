//
//  DADiffDeltaGraphView.h
//  Gitty
//
//  Created by kernel on 8/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DADiffDeltaGraphView : UIView
@property (strong, nonatomic) GTDiffDelta *delta;

@property () NSUInteger squaresNumber;
@property () CGFloat squaresMargin;
@end
