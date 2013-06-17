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
	BOOL isCredentialsContainerShown;
}

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
	isCredentialsContainerShown = !isCredentialsContainerShown;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		CGFloat offset = self.credentialsContainer.height;
		if (isCredentialsContainerShown) {
			[self showAnonymousButton];
		} else {
			[self showLoginButton];
			offset *= -1;
		}
		self.exploreContainer.height += offset;
	}];
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
