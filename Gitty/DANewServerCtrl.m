//
//  DANewServer.m
//  Gitty
//
//  Created by kernel on 17/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DANewServerCtrl.h"

@interface DANewServerCtrl ()
@end

@implementation DANewServerCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.createButton.layer.cornerRadius = 35.;
	
	[self.serverNameField applyThinStyle];
	[self.serverUrlField applyThinStyle];
}

- (void)resetFields {
	self.serverNameField.text = nil;
	self.serverUrlField.text = nil;
	
	self.createButton.enabled = NO;
}

- (void)disableFeatureWithNotice:(NSString *)message {
	self.noticeLabel.text = message;
	self.noticeLabel.hidden = NO;
	
	self.serverNameField.enabled = NO;
	self.serverUrlField.enabled = NO;
}

#pragma mark Actions

- (IBAction)hostLinkPressed:(UIButton *)sender {
	NSURL *url = [NSURL URLWithString:@"http://gitup.reimplement.mobi/2013/07/private-git-server.html"];
	
	[UIApplication.sharedApplication openURL:url];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (textField == self.serverUrlField) {
		self.createButton.enabled = self.serverNameField.text.length && resultString.length;
		
		return string.isUrlSuitable;
	} else if (textField == self.serverNameField) {
		self.createButton.enabled = self.serverUrlField.text.length && resultString.length;
		
		return string.isServerNameSuitable;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField == self.serverUrlField) {
		[self.serverNameField becomeFirstResponder];
	}
	return YES;
}

@end
