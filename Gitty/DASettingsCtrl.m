//
//  DASettingsCtrl.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASettingsCtrl.h"
#import "DACreateServerTopMargin.h"
#import "DAGitServer+Creation.h"

@interface DASettingsCtrl ()
@property (strong, nonatomic, readonly) NSArray *servers;
@property (strong, nonatomic, readonly) NSLayoutConstraint *createContainerTopMargin;
@end

@implementation DASettingsCtrl
@dynamic servers;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.createButton.layer.cornerRadius = 6.;
	[self.createButton applyShadowOfRadius:3. withColor:UIColor.blackColor];
	
	self.createServerButton.layer.cornerRadius = 6.;
	[self.createServerButton applyShadowOfRadius:3. withColor:UIColor.blackColor];
	
	[self.serverContainer applyShadowOfRadius:3. withColor:UIColor.blackColor];
	
	[self.table registerClass:UITableViewCell.class forCellReuseIdentifier:UITableViewCell.className];
	
	[self setupConstraints];
}

- (void)setupConstraints {
	for (NSLayoutConstraint *constraint in self.view.constraints) {
		if ([constraint isKindOfClass:DACreateServerTopMargin.class]) {
			_createContainerTopMargin = constraint;
			break;
		}
	}
	
	self.createContainerTopMargin.constant = self.table.height;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[self.table setEditing:editing animated:animated];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.servers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DAGitServer *server = self.servers[indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCell.className];
	
	cell.textLabel.text = server.name;
	cell.detailTextLabel.text = server.gitBaseUrl;
	
	return cell;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField == self.urlField) {
		[self.nameField becomeFirstResponder];
	}
	
	return YES;
}

#pragma mark Properties

- (NSArray *)servers {
	return DAServerManager.manager.list;
}

#pragma mark Actions

- (IBAction)showCreationDialog:(UIButton *)sender {
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		self.createContainerTopMargin.constant = .0;
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		self.createButton.backgroundColor = UIColor.darkGrayColor;
	}];
}

- (IBAction)createNewServer:(UIButton *)sender {
	BOOL isValid = [self validateUserInput];
	if (!isValid) {
		return;
	}
	
	[self createServerAndSave];
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
		self.createContainerTopMargin.constant = self.table.height;
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		self.createButton.backgroundColor = UIColor.acceptingGreenColor;
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}];
}

- (BOOL)validateUserInput {
	if (0 == self.urlField.text.length) {
		[self.urlField becomeFirstResponder];
		return NO;
	} else if (0 == self.nameField.text.length) {
		[self.nameField becomeFirstResponder];
		return NO;
	}
	return YES;
}

- (void)createServerAndSave {
	DAGitServer *server = [self createServerObjectFromUserInput];
	[DAServerManager.manager addNewServer:server];
}

// TODO: Check isServerNameUnique & isServerSavePathUnique.
- (DAGitServer *)createServerObjectFromUserInput {
	static NSString *protocol = @"git://";
	
	NSString *url = [[protocol concat:self.urlField.text] concat:@"/"];
	
	NSDictionary *info = @{ServerName: self.nameField.text,
						   ServerGitBaseUrl: url,
						   SaveDirectory: self.nameField.text};
	
	return [DAGitServer serverWithDictionary:info];
}

@end
