//
//  DAModifiedHeader.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAStatusHeader : UIView
- (void)loadDelta:(GTDiffDelta *)delta;

@property (strong, nonatomic) IBOutlet UILabel *filenameLabel, *anotherFilenameLabel;
@property (strong, nonatomic) IBOutlet UILabel *symbolLabel, *anotherSymbolLabel;
@property (strong, nonatomic) IBOutlet UIView *bluringBackground;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@end
