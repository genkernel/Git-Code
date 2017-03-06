//
//  UIApplication+Gitty.h
//  Git Code
//
//  Created by Anthony on 3/5/17.
//  Copyright © 2017 ReImpl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Gitty)
@property (strong, nonatomic, readonly) NSFileManager *fs;
@property (strong, nonatomic, readonly) UIViewController *rootCtrl;

@property (strong, nonatomic, readonly) NSString *cachesPath, *documentsPath;
@end
