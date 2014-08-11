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
	
	self.continueButton.layer.cornerRadius = 2.;
	
	UIImage *blueImg = [UIImage resizableImageFromColor:RGB(0, 122, 255)];
	UIImage *greyImg = [UIImage resizableImageFromColor:RGB(170, 170, 170)];
	
	[self.continueButton setBackgroundImage:blueImg forState:UIControlStateNormal];
	[self.continueButton setBackgroundImage:greyImg forState:UIControlStateHighlighted];
}

- (IBAction)continuePressed:(UIButton *)sender {
	[self.alertPresenter dismissAnimated:YES];
}

@end
