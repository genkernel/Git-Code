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

@implementation DAServerCtrl {
	CGFloat progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setEditing:YES animated:NO];
	
	((PagerItemView *)self.view).identifier = self.className;
	
	[self.loginButton applyBlueStyle];
	[self.exploreButton applyGreenStyle];
	
	[self.repoField applyThinStyle];
	[self.userNameField applyThinStyle];
	[self.userPasswordField applyThinStyle];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	self.repoField.enabled = editing;
	self.userNameField.enabled = editing;
	self.userPasswordField.enabled = editing;
}

- (void)loadServer:(DAGitServer *)server {
	self.serverName.text = server.name;
	self.logoIcon.image = [UIImage imageNamed:server.logoIconName];
}

- (void)setProgress:(CGFloat)updatedProgress {
	if (updatedProgress < .0 || updatedProgress > 1.) {
		[Logger error:@"Invalid progress specified. %s", __PRETTY_FUNCTION__];
        return;
    }
	
	if (progress >= updatedProgress) {
		return;
	}
	
	progress = updatedProgress;
	
	[self.repoField setProgress:progress progressColor:UIColor.acceptingGreenColor backgroundColor:UIColor.whiteColor];
}

- (void)resetProgress {
	progress = .0;
	
	self.repoField.background = nil;
	self.repoField.disabledBackground = nil;
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return [string isUrlSuitable];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (0 == textField.text.length > 0) {
		return NO;
	}
	
	[textField resignFirstResponder];
	
	if (self.isUsingCredentials && textField == self.repoField) {
		[self.userNameField becomeFirstResponder];
	} else if (textField == self.userNameField) {
		[self.userPasswordField becomeFirstResponder];
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
	[self.loginButton applyBlueStyle];
	[self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
}

@end
