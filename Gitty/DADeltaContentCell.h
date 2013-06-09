//
//  DADeltaContentCell.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAHunkContentView.h"

@interface DADeltaContentCell : UITableViewCell
- (void)loadDelta:(GTDiffDelta *)delta;

@property (strong, nonatomic) IBOutlet UIScrollView *scroll;
@end
