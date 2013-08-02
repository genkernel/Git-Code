//
//  DASshInfoCtrl.m
//  Gitty
//
//  Created by kernel on 26/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASshInfoCtrl.h"

@interface DASshInfoCtrl ()
@end

@implementation DASshInfoCtrl

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.webView disableBounces];
	
	[self loadHtmlGuide];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[DAFlurry logScreenAppear:self.className];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[DAFlurry logScreenDisappear:self.className];
}

- (void)loadHtmlGuide {
	NSURL *url = [NSBundle.mainBundle URLForResource:@"SSH-Howto" withExtension:@"html"];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark Actions

- (IBAction)closePressed:(UIBarButtonItem *)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
