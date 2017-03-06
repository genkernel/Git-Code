//
//  DAFeedbackCtrl.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAFeedbackCtrl.h"

@implementation DAFeedbackCtrl

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Ok" style:UIBarButtonItemStyleDone target:self action:@selector(closePressed:)];
	
#warning disabled
//	[self.webView disableBounces];
	
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
	NSURL *url = [NSBundle.mainBundle URLForResource:@"Feedback" withExtension:@"html"];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	BOOL isHttp = [request.URL.scheme isEqualToString:@"http"];
	BOOL isHttps = [request.URL.scheme isEqualToString:@"https"];
	BOOL isEmail = [request.URL.scheme isEqualToString:@"mailto"];
	if (isHttp || isHttps || isEmail) {
		[self.app openURL:request.URL];
		return NO;
	}
	
	return YES;
}

#pragma mark Actions

- (IBAction)closePressed:(UIBarButtonItem *)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
