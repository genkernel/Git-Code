//
//  UI-Constants.h
//  xlib
//
//  Created by Altukhov Anton on 10/1/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#ifndef xlib_UI_Constants_h
#define xlib_UI_Constants_h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//#import "shared.h"

#import "Service.h"

#define	UIViewAutoResizingMargins	(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin)
#define	UIViewAutoResizingView	(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)
#define	UIViewAutoResizingAll	(UIViewAutoResizingView | UIViewAutoResizingMargins)

static const NSTimeInterval LightningAnimationDuration = 0.200;
static const NSTimeInterval StandardAnimationDuration = 0.350;
static const NSTimeInterval SmoothAnimationDuration = 0.650;
static const NSTimeInterval ExtraAnimationDuration = 0.950;

// example usage: UIColorFromHex(0x9daa76)
#define UIColorFromHex(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]
#define	RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define	RGB(r,g,b) RGBA(r, g, b, 1.)

#endif
