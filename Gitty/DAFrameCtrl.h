//
//  DAFrameCtrl.h
//  Gitty
//
//  Created by kernel on 21/09/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DABaseCtrl;

typedef enum {
	// Fading in/out.
	DAAlphaFadePresentation,
	// Private option: DAAlphaFadeHidePresentation.
	DAAlphaFadeHidePresentation,
	
	// Sliding.
	DASlideFromLeftToRightPresentation,
	DASlideFromRightToLeftPresentation,
	DASlideFromTopToBottomPresentation,
	DASlideFromBottomToTopPresentation,
	// Private option: DASlideToCenterPresentation.
	DASlideToCenterPresentation
	
} DAFramePresentingAnimations;

@interface DAFrameCtrl : UIViewController
@property (strong, nonatomic) IBOutlet UIView *mainContainer, *overlayContainer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *overlayTop, *overlayLeft, *overlayRight, *overlayBottom;
@end
