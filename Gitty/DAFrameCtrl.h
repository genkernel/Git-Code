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
@property (strong, nonatomic) IBOutlet UIView *mainContainer, *overlayContainer, *menuContainer;
@property (strong, nonatomic) IBOutlet UIView *dismissMainOverlay;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainTop, *mainLeft, *mainRight, *mainBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *overlayTop, *overlayLeft, *overlayRight, *overlayBottom;

- (void)presentMenuCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated animationOption:(DAFramePresentingAnimations)option;
- (void)dismissMenuCtrl:(DABaseCtrl *)ctrl animated:(BOOL)animated;
@end
