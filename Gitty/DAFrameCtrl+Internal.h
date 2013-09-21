//
//  DAFrameCtrl+Internal.h
//  Gitty
//
//  Created by kernel on 21/09/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAFrameCtrl.h"

@interface DAFrameCtrl ()
@property (strong, nonatomic, readonly) DABaseCtrl *mainCtrl, *overlayCtrl;

- (void)presentOverlayCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated animationOption:(DAFramePresentingAnimations)option;
- (void)dismissOverlayCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated;
@end
