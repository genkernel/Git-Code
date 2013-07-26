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

- (void)loadHtmlGuide {
	NSURL *url = [NSBundle.mainBundle URLForResource:@"SSH-Howto" withExtension:@"html"];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark Actions

- (IBAction)closePressed:(UIBarButtonItem *)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
