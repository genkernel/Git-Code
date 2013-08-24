//
//  DASupportTipCtrl.m
//  Gitty
//
//  Created by kernel on 24/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DASupportTipCtrl.h"

@interface DASupportTipCtrl ()

@end

@implementation DASupportTipCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.gotItButton applyBlueStyle];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[UIView animateWithDuration:SmoothAnimationDuration animations:^{
		self.view.alpha = 1;
	}];
}

#pragma mark Actions

- (IBAction)gotItPressed:(UIButton *)sender {
	[self.alertPresenter dismissAnimated:YES];
}

@end
