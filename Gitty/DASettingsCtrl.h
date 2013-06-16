//
//  DASettingsCtrl.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DASettingsCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIButton *createButton, *createServerButton;
@property (strong, nonatomic) IBOutlet UIView *createContainer, *serverContainer;
@property (strong, nonatomic) IBOutlet UITextField *urlField, *nameField;


@end
