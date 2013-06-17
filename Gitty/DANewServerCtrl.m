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
	
	[self.createButton applyGreenStyle];
}

- (void)resetFields {
	self.serverNameField.text = nil;
	self.serverUrlField.text = nil;
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
