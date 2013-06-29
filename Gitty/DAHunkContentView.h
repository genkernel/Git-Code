//
//  DAHunkView.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAHunkContentView : UIView
- (void)loadHunk:(GTDiffHunk *)hunk;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@end
