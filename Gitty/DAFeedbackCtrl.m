//
//  DAFeedbackCtrl.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAFeedbackCtrl.h"

@interface DAFeedbackCtrl ()
@end

@implementation DAFeedbackCtrl

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.webView disableBounces];
	
	[self loadHtmlGuide];
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
