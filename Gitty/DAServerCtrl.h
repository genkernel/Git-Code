//
//  DAServerCtrl.h
//  Gitty
//
//  Created by kernel on 16/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DAServerCtrl : DABaseCtrl <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *repoField, *userNameField, *userPasswordField;
@property (strong, nonatomic) IBOutlet UIButton *exploreButton, *loginButton;
@property (strong, nonatomic) IBOutlet UIImageView *logoIcon;
@property (strong, nonatomic) IBOutlet UILabel *serverName;
@property (strong, nonatomic) IBOutlet UIView *exploreContainer, *credentialsContainer;

- (void)loadServer:(DAGitServer *)server;
- (void)setProgress:(CGFloat)progress;
- (void)resetProgress;

@property () BOOL isUsingCredentials;
@end
