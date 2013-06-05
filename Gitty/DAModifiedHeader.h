//
//  DAModifiedHeader.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAModifiedHeader : UIView
- (void)loadDelta:(GTDiffDelta *)delta;


@property (strong, nonatomic) IBOutlet UILabel *filenameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *graphImage;

@end
