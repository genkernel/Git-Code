//
//  PageControl.h
//  Gitty
//
//  Created by kernel on 2/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PageControlDelegate;

@interface PageControl : UIPageControl
@property (weak, nonatomic) IBOutlet id<PageControlDelegate> delegate;
@end

@protocol PageControlDelegate <NSObject>
@required
- (UIImage *)activeImageForIndex:(NSUInteger)index;
- (UIImage *)inactiveImageForIndex:(NSUInteger)index;
@end