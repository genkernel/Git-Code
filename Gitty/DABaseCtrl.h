//
//  DABaseCtrl.h
//  Gitty
//
//  Created by kernel on 29/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DABaseCtrl : UIViewController
@property (strong, nonatomic, readonly) DAGitManager *git;
@property (strong, nonatomic, readonly) DAServerManager *servers;
@property (strong, nonatomic, readonly) UIApplication *app;
@end
