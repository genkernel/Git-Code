//
//  DADeltaContentCell.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAHunkContentView.h"

@class DADeltaContentScrollView;

@interface DADeltaContentCell : UITableViewCell
- (void)loadDelta:(GTDiffDelta *)delta withLongestLineOfWidth:(CGFloat)width;

@property (strong, nonatomic) IBOutlet DADeltaContentScrollView *scroll;
@end

@interface DADeltaContentScrollView : UIScrollView
@end