//
//  DAModifiedHeader.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADiffDeltaGraphView.h"

@interface DAModifiedHeader : UIView
- (void)loadDelta:(GTDiffDelta *)delta;

@property (strong, nonatomic) IBOutlet DADiffDeltaGraphView *graph;
@property (strong, nonatomic) IBOutlet UILabel *filenameLabel;
@property (strong, nonatomic) IBOutlet UILabel *binaryStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *additionsLabel, *deletionsLabel;
@end
