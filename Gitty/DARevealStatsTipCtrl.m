//
//  DARevealStatsTipCtrl.m
//  Gitty
//
//  Created by Altukhov Anton on 8/11/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DARevealStatsTipCtrl.h"

@interface DARevealStatsTipCtrl ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@end

@implementation DARevealStatsTipCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.continueButton applyBlueStyle];
}

#pragma mark Actions

- (IBAction)continuePressed:(UIButton *)sender {
	[self.alertPresenter dismissAnimated:YES];
}

@end
