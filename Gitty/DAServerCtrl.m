//
//  DAServerCtrl.m
//  Gitty
//
//  Created by kernel on 16/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAServerCtrl.h"
#import "DAServerCtrl+Animation.h"

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
@synthesize isUsingCredentials = isCredentialsVisible;
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
	
	self.repoField.rightView = self.recentReposButton;
	self.repoField.rightViewMode = UITextFieldViewModeUnlessEditing;
	
	self.userNameField.rightView = self.lockUsernameButton;
	self.userNameField.rightViewMode = UITextFieldViewModeAlways;
	
	self.userPasswordField.rightView = self.lockPasswordButton;
	self.userPasswordField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	self.repoField.enabled = editing;
	self.userNameField.enabled = editing;
	self.userPasswordField.enabled = editing;
}

- (void)loadServer:(DAGitServer *)server {
	_server = server;
	
	[self reloadCurrentServer];
}

- (void)reloadCurrentServer {
	BOOL isGithubServer = 0 == [self.servers.list indexOfObject:self.server];
	self.repoField.inputAccessoryView = isGithubServer ? self.repoAccessoryView : nil;
	
	self.serverName.text = self.server.name;
	self.repoField.text = self.server.recentRepoPath;
	self.logoIcon.image = [UIImage imageNamed:self.server.logoIconName];
	
	[self loadProtocolsWithServer:self.server];
	[self resetBaseUrlLabel];
	
	[self reloadCredentials];
	[self updateControlButtonsState];
}

- (void)resetBaseUrlLabel {
	self.serverBaseUrl.text = [[self.selectedProtocol concat:self.server.gitBaseUrl] concat:@"/"];
}

-(void)reloadCredentials {
	NSString *username = [DAAccountCredentials.manager getPasswordForUsername:UsernameKey atServer:self.server];
	{
		self.userNameField.text = username;
		self.lockUsernameButton.enabled = username != nil;
		self.lockUsernameButton.selected = username != nil;
	}
	
	NSString *password = [DAAccountCredentials.manager getPasswordForUsername:PasswordKey atServer:self.server];
	{
		self.userPasswordField.text = password;
		self.lockPasswordButton.enabled = password != nil;
		self.lockPasswordButton.selected = password != nil;
	}
	
	BOOL hasUsernameOrPassword = username || password;
	[self setCredentialsVisible:hasUsernameOrPassword animated:NO];
}

- (void)resetCredentials {
	self.userNameField.text = nil;
	self.userPasswordField.text = nil;
	
	[self setCredentialsVisible:NO animated:NO];
}

- (void)loadProtocolsWithServer:(DAGitServer *)server {
	_selectedProtocolButton = nil;
	
	[self.protocolsContainer removeAllSubviews];
	
	DAProtocolsContainer *container = [DAProtocolsContainer.alloc initWithFrame:self.protocolsContainer.bounds];
	container.translatesAutoresizingMaskIntoConstraints = NO;
	[container removeAllButtonsAndResetLayout];
	
	[self.protocolsContainer addSubview:container];
	
	NSMutableSet *protocols = [NSMutableSet setWithArray:server.supportedProtocols];
	
	BOOL isSshSupportedByServer = [DASshCredentials.manager hasSshKeypairSupportForServer:server];
//	BOOL isSshGloballySupported = DASshCredentials.manager.hasSshKeypairGlobalSupport;
	
	if (isSshSupportedByServer/* || isSshGloballySupported*/) {
		[protocols addObject:SshTransferProtocol];
	}
	
	for (NSString *protocol in protocols) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button applyProtocolStyle];
		
		button.translatesAutoresizingMaskIntoConstraints = NO;
		
		[button setTitle:protocol forState:UIControlStateNormal];
		[button sizeToFit];
		
		[container insertAndLayoutNextProtocolButton:button];
		
		if ([server.transferProtocol isEqualToString:protocol]) {
			_selectedProtocolButton = button;
		}
		
		[button addTarget:self action:@selector(protocolSelected:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	if (!self.selectedProtocolButton) {
		[Logger error:@"No transfer protocol selected by default."];
		_selectedProtocolButton = container.subviews.anyObject;
	}
	
	self.selectedProtocolButton.enabled = NO;
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

- (void)lockSecureFieldForKey:(NSString *)key value:(NSString *)value {
	[DAAccountCredentials.manager saveUsername:key password:value onServer:self.server];
}

- (void)unlockSecureFieldForKey:(NSString *)key {
	[DAAccountCredentials.manager deleteUsername:key fromServer:self.server];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField == self.userNameField) {
		self.lockUsernameButton.selected = NO;
		[self unlockSecureFieldForKey:UsernameKey];
	} else if (textField == self.userPasswordField) {
		self.lockPasswordButton.selected = NO;
		[self unlockSecureFieldForKey:PasswordKey];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if (textField == self.repoField) {
		return [string isUrlSuitable];
	}
	
	UIButton *lockers[] = {self.lockUsernameButton, self.lockPasswordButton};
	UIButton *locker = lockers[textField.tag];
	
	NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	locker.enabled = newString.length > 0;
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (0 == textField.text.length) {
		return NO;
	}
	
	[textField resignFirstResponder];
	
	if (self.isUsingCredentials && textField == self.repoField) {
		[self.userNameField becomeFirstResponder];
	} else if (textField == self.userNameField) {
		[self.userPasswordField becomeFirstResponder];
	}
	
	[self updateControlButtonsState];
	
	return YES;
}

#pragma mark Actions

- (IBAction)didClickLogin:(UIButton *)sender {
	[self setCredentialsVisible:!self.isUsingCredentials animated:YES];
}

- (IBAction)protocolSelected:(UIButton *)sender {
	self.selectedProtocolButton.enabled = YES;
	sender.enabled = NO;
	
	_selectedProtocolButton = sender;
	
	self.server.transferProtocol = self.selectedProtocol;
	
	[self resetBaseUrlLabel];
}

- (IBAction)lockOrUnlockField:(UIButton *)sender {
	sender.selected = !sender.selected;
	
	UITextField *fields[] = {self.userNameField, self.userPasswordField};
	UITextField *field = fields[sender.tag];
	
	NSString *keys[] = {UsernameKey, PasswordKey};
	NSString *key = keys[sender.tag];
	
	if (sender.selected) {
		if (0 == sender.tag) {
			if (self.userNameField.isFirstResponder) {
				[self.userPasswordField becomeFirstResponder];
			}
		} else {
			[self.userPasswordField resignFirstResponder];
			[self updateControlButtonsState];
		}
		
		[self lockSecureFieldForKey:key value:field.text];
		
	} else {
		[self unlockSecureFieldForKey:key];
	}
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
