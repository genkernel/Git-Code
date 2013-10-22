//
//  DASshInfoCtrl.m
//  Gitty
//
//  Created by kernel on 26/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASshInfoCtrl.h"

@implementation DASshInfoCtrl

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Got It" style:UIBarButtonItemStyleDone target:self action:@selector(closePressed:)];
	
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

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	if (UIWebViewNavigationTypeLinkClicked == navigationType) {
		[UIApplication.sharedApplication openURL:request.URL];
		return NO;
	}
	return YES;
}

#pragma mark Actions

- (IBAction)closePressed:(UIBarButtonItem *)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
