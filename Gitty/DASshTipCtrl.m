//
//  DASshTipCtrl.m
//  Gitty
//
//  Created by kernel on 22/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DASshTipCtrl.h"

@interface DASshTipCtrl ()

@end

@implementation DASshTipCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	{
		UIImage *img = [UIImage imageNamed:@"popup_arrow-light.png"];
		img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(8, 46, 28, 10)];
		
		self.border.image = img;
	}
	
	[self.gotItButton applyBlueStyle];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[UIView animateWithDuration:SmoothAnimationDuration animations:^{
		self.view.alpha = 1;
	}];
}

#pragma mark Actions

- (IBAction)gitItPressed:(UIButton *)sender {
	[self.alertPresenter dismissAnimated:YES];
}

@end
