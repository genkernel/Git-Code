//
//  DAFrameCtrl+States.m
//  Gitty
//
//  Created by kernel on 21/09/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAFrameCtrl+States.h"

@implementation DAFrameCtrl (States)
/*
- (DAFramePresentingAnimations)reversedOptionForOption:(DAFramePresentingAnimations)option {
	switch (option) {
		case DASlideFromLeftToRightPresentation:
			return DASlideFromRightToLeftPresentation;
		case DASlideFromRightToLeftPresentation:
			return DASlideFromLeftToRightPresentation;
			
		case DASlideFromTopToBottomPresentation:
			return DASlideFromBottomToTopPresentation;
		case DASlideFromBottomToTopPresentation:
			return DASlideFromTopToBottomPresentation;
			
		case DASlideToCenterPresentation:
			return DASlideToCenterPresentation;
			
		case DAAlphaFadePresentation:
			return DAAlphaFadeHidePresentation;
		case DAAlphaFadeHidePresentation:
			return DAAlphaFadePresentation;
	}
}*/

- (CGFloat)alphaForOption:(DAFramePresentingAnimations)option {
	return DAAlphaFadePresentation == option ? 0 : 1;
}

- (CGPoint)marginsForOption:(DAFramePresentingAnimations)option {
	CGFloat x = 0, y = 0;
	
	switch (option) {
		case DASlideFromLeftToRightPresentation:
			x = -self.overlayContainer.width;
			break;
		case DASlideFromRightToLeftPresentation:
			x = self.overlayContainer.width;
			break;
			
		case DASlideFromTopToBottomPresentation:
			y = -self.overlayContainer.height;
			break;
		case DASlideFromBottomToTopPresentation:
			y = self.overlayContainer.height;
			break;
			
		default:
			break;
	}
	
	return CGPointMake(x, y);
}

@end
