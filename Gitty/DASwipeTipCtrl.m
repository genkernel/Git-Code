//
//  DASwipeTipCtrl.m
//  Gitty
//
//  Created by Altukhov Anton on 8/11/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DASwipeTipCtrl.h"

@interface DASwipeTipCtrl ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@end

@implementation DASwipeTipCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.continueButton applyBlueStyle];
}

- (IBAction)continuePressed:(UIButton *)sender {
	[self.alertPresenter dismissAnimated:YES];
}

@end
