//
//  DAServerCtrl+Animation.m
//  Gitty
//
//  Created by kernel on 6/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAServerCtrl+Animation.h"

@implementation DAServerCtrl (Animation)

- (void)setCredentialsVisible:(BOOL)visible animated:(BOOL)animated {
	if (isCredentialsVisible == visible) {
		return;
	}
	isCredentialsVisible = visible;
	
	if (visible) {
		[self showAnonymousButton];
	} else {
		[self showLoginButton];
	}
	
	CGFloat offset = self.credentialsContainer.height;
	offset *= visible ? 1 : -1;
	
	self.exploreContainerHeight.constant += offset;
	
	[UIView animateWithDuration:StandardAnimationDuration animations:^{
		[self.exploreContainer layoutIfNeeded];
	} completion:^(BOOL finished) {
		[self updateControlButtonsState];
	}];
}

- (void)showAnonymousButton {
	self.loginButton.backgroundColor = UIColor.cancelingRedColor;
	[self.loginButton setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
	
	[self.loginButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

- (void)showLoginButton {
	self.loginButton.backgroundColor = UIColor.acceptingBlueColor;
	[self.loginButton setBackgroundImage:[UIImage imageNamed:@"btn-blue.png"] forState:UIControlStateNormal];
	
	[self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
}

- (void)updateControlButtonsState {
	if (self.isUsingCredentials) {
		BOOL isCredentialsSupplied = self.userNameField.text.length && self.userPasswordField.text.length;
		self.exploreButton.enabled = self.repoField.text.length && isCredentialsSupplied;
		
	} else {
		self.exploreButton.enabled = self.repoField.text.length > 0;
	}
}

@end
