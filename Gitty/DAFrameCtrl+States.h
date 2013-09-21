//
//  DAFrameCtrl+States.h
//  Gitty
//
//  Created by kernel on 21/09/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAFrameCtrl.h"

@interface DAFrameCtrl (States)
- (CGFloat)alphaForOption:(DAFramePresentingAnimations)option;
- (CGPoint)marginsForOption:(DAFramePresentingAnimations)option;

//- (DAFramePresentingAnimations)reversedOptionForOption:(DAFramePresentingAnimations)option;
@end
