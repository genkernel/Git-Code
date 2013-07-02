//
//  DAServerCtrl.m
//  Gitty
//
//  Created by kernel on 16/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAServerCtrl.h"
#import "DAServerCtrl+AutoLayout.h"

@interface UIButton (ServerCtrlLayout)
- (void)applyProtocolStyle;
@end

@interface DAServerCtrl ()
@property (weak, nonatomic, readonly) DAGitServer *server;

@property (strong, nonatomic, readonly) UIButton *selectedProtocolButton;
@end

@implementation DAServerCtrl {
	CGFloat progress;
}
@dynamic selectedProtocol;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setEditing:YES animated:NO];
	
	((PagerItemView *)self.view).identifier = self.className;
	
	self.loginButton.layer.cornerRadius = 35.;
	self.exploreButton.layer.cornerRadius = 35.;
	
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
	_server = server;
	
	self.serverName.text = server.name;
	self.logoIcon.image = [UIImage imageNamed:server.logoIconName];
	
	[self loadProtocolsWithServer:server];
	[self resetBaseUrlLabel];
}

- (void)resetBaseUrlLabel {
	self.serverBaseUrl.text = [[self.selectedProtocol concat:self.server.gitBaseUrl] concat:@"/"];
}

- (void)loadProtocolsWithServer:(DAGitServer *)server {
	_selectedProtocolButton = nil;
	
	[self.protocolsContainer removeAllSubviews];
	
	self.protocolsContainer.translatesAutoresizingMaskIntoConstraints = NO;
	[self.protocolsContainer removeConstraints:self.protocolsContainer.constraints];
	
	[self layoutProtocolsContainer];
	
	for (NSString *protocol in server.supportedProtocols) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button applyProtocolStyle];
		
		button.translatesAutoresizingMaskIntoConstraints = NO;
		
		[button setTitle:protocol forState:UIControlStateNormal];
		[button sizeToFit];
		
		[self insertAndLayoutNextProtocolButton:button];
		
		if ([server.transferProtocol isEqualToString:protocol]) {
			_selectedProtocolButton = button;
		}
		
		[button addTarget:self action:@selector(protocolSelected:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	if (!self.selectedProtocolButton) {
		[Logger error:@"No transfer protocol selected by default."];
//		_selectedProtocolButton = self.protocolButtons[0];
	}
	
	self.selectedProtocolButton.enabled = NO;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.protocolsContainer invalidateIntrinsicContentSize];
		[self.protocolsContainer setNeedsUpdateConstraints];
	});
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

- (void)startProgressing {
	[self.exploreButton setTitle:nil forState:UIControlStateNormal];
	[self.exploringIndicator startAnimating];
}

- (void)resetProgress {
	progress = .0;
	
	[self.exploringIndicator stopAnimating];
	[self.exploreButton setTitle:NSLocalizedString(@"Explore", nil) forState:UIControlStateNormal];
	
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
	self.loginButton.backgroundColor = UIColor.cancelingRedColor;
	[self.loginButton setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
	
	[self.loginButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

- (void)showLoginButton {
	self.loginButton.backgroundColor = UIColor.acceptingBlueColor;
	[self.loginButton setBackgroundImage:[UIImage imageNamed:@"btn-blue.png"] forState:UIControlStateNormal];
	
	[self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
}

- (IBAction)protocolSelected:(UIButton *)sender {
	self.selectedProtocolButton.enabled = YES;
	sender.enabled = NO;
	
	_selectedProtocolButton = sender;
	
	self.server.transferProtocol = self.selectedProtocol;
	
	[self resetBaseUrlLabel];
}

#pragma mark Properties

- (NSString *)selectedProtocol {
	return [self.selectedProtocolButton titleForState:UIControlStateNormal];
}

@end


@implementation UIButton (ServerCtrlLayout)

- (void)applyProtocolStyle {
	self.layer.cornerRadius = 3.;
	self.layer.masksToBounds = YES;
	
	[self setContentEdgeInsets:UIEdgeInsetsMake(.0, 4., .0, 4.)];
	self.titleLabel.font = [UIFont fontWithName:@"Cochin-Bold" size:15];
	
	UIImage *img = [UIImage imageNamed:@"btn-lightgray.png"];
	UIImage *selectedImg = [UIImage imageNamed:@"btn-blue.png"];
	
	[self setBackgroundImage:img forState:UIControlStateNormal];
	[self setBackgroundImage:selectedImg forState:UIControlStateDisabled];
	
	[self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
	[self setTitleColor:UIColor.whiteColor forState:UIControlStateDisabled];
}

@end
