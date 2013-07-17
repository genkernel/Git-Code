//
//  DAServerCtrl.h
//  Gitty
//
//  Created by kernel on 16/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"
#import "DAProtocolsContainer.h"

@interface DAServerCtrl : DABaseCtrl <UITextFieldDelegate> {
	BOOL isCredentialsVisible;
}
@property (strong, nonatomic) IBOutlet UITextField *repoField, *userNameField, *userPasswordField;
@property (strong, nonatomic) IBOutlet UIButton *exploreButton, *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *exploringIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *logoIcon;
@property (strong, nonatomic) IBOutlet UILabel *serverName, *serverBaseUrl;
@property (strong, nonatomic) IBOutlet UIView *exploreContainer, *credentialsContainer;
@property (strong, nonatomic) IBOutlet DAProtocolsContainer *protocolsContainer;
@property (strong, nonatomic) IBOutlet UIToolbar *repoAccessoryView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *exploreContainerHeightRule;

- (void)loadServer:(DAGitServer *)server;
- (void)reloadCurrentServer;
- (void)startProgressing;
- (void)setProgress:(CGFloat)progress;
- (void)resetProgress;
- (void)resetCredentials;

@property (readonly) BOOL isUsingCredentials;
@property (strong, nonatomic, readonly) NSString *selectedProtocol;
@end
