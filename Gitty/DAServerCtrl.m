//
//  DAServerCtrl.m
//  Gitty
//
//  Created by kernel on 16/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAServerCtrl.h"

@interface DAServerCtrl ()
@end

@implementation DAServerCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	((PagerItemView *)self.view).identifier = self.className;
	
	[self.exploreButton applyBlueStyle];
	[self.loginButton applyGreenStyle];
}

- (void)loadServer:(DAGitServer *)server {
	self.serverName.text = server.name;
	self.logoIcon.image = [UIImage imageNamed:server.logoIconName];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9a-zA-Z/-]*"];
	return [predicate evaluateWithObject:string];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField.text.length > 0) {
////		[self testRepoWithUserString:textField.text];
	}
	
	return YES;
}

#pragma mark Actions

- (IBAction)didClickLogin:(UIButton *)sender {
	_isUsingCredentials = !self.isUsingCredentials;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		CGFloat offset = self.credentialsContainer.height;
		if (self.isUsingCredentials) {
			[self showAnonymousButton];
		} else {
			[self showLoginButton];
			offset *= -1;
		}
		self.exploreContainer.height += offset;
	} completion:^(BOOL finished) {
		[self updateControlButtonsState];
	}];
}

- (void)updateControlButtonsState {
	if (self.isUsingCredentials) {
		BOOL isCredentialsSupplied = self.userNameField.text.length && self.userPasswordField.text.length;
		self.exploreButton.enabled = self.repoField.text.length && isCredentialsSupplied;
	} else {
		self.exploreButton.enabled = self.repoField.text.length;
	}
}

- (void)showAnonymousButton {
	[self.loginButton applyRedStyle];
	[self.loginButton setTitle:@"Anonymous" forState:UIControlStateNormal];
}

- (void)showLoginButton {
	[self.loginButton applyGreenStyle];
	[self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
}

@end
