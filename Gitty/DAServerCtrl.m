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
	
	[self.exploreButton applyBlueStyle];
	[self.loginButton applyGreenStyle];
	
	self.repoField.layer.borderColor = UIColor.lightGrayColor.CGColor;
	self.repoField.layer.borderWidth = 1.;
	self.repoField.layer.cornerRadius = 5.;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	self.repoField.enabled = editing;
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
