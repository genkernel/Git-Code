//
//  DABaseCtrl.h
//  Gitty
//
//  Created by kernel on 29/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAFrameCtrl.h"

@interface DABaseCtrl : ViewCtrl
@property (nonatomic) DAFramePresentingAnimations presentationOption;

@property (strong, nonatomic, readonly) DAGitManager *git;
@property (strong, nonatomic, readonly) DAServerManager *servers;
@property (strong, nonatomic, readonly) UIApplication *app;
@property (strong, nonatomic, readonly) DAFrameCtrl *frameCtrl;

- (UIView *)cachedViewWithIdentifier:(NSString *)identifier;
- (void)cacheView:(UIView *)view withIdentifier:(NSString *)identifier;
@end
