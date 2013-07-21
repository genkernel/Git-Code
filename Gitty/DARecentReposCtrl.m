//
//  DARecentReposCtrl.m
//  Gitty
//
//  Created by kernel on 21/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARecentReposCtrl.h"
#import "DARepoCell.h"

@interface DARecentReposCtrl ()
@property (strong, nonatomic, readonly) NSArray *repos;
@end

@implementation DARecentReposCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_repos = self.server.reposByAccessTime.copy;
	
	BOOL shouldShowEmptyMessage = self.repos.count == 0;
	self.emptyLabel.hidden = !shouldShowEmptyMessage;
	self.reposTable.hidden = shouldShowEmptyMessage;
	
	NSString *identifier = DARepoCell.className;
	UINib *nib = [UINib nibWithNibName:identifier bundle:nil];
	[self.reposTable registerNib:nib forCellReuseIdentifier:identifier];
	
//	[self loadServerLogoImage];
}

- (void)loadServerLogoImage {
	[self.customLogo applyAvatarStyle];
	self.customLogo.image = [UIImage imageNamed:self.server.logoIconName];
	
	UIBarButtonItem *rightButton = [UIBarButtonItem.alloc initWithCustomView:self.customLogo];
	self.customNavigationItem.rightBarButtonItem = rightButton;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DARepoCell *cell = [tableView dequeueReusableCellWithIdentifier:DARepoCell.className];
	
	[cell loadRepo:self.repos[indexPath.row]];
	
	NSString *name = indexPath.row % 2 ? @"Git-Icon.png" : @"Git-Icon_red.png";
	cell.logo.image = [UIImage imageNamed:name];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	self.selectAction(self.repos[indexPath.row]);
}

#pragma mark Actions

- (IBAction)cancelDidClicked:(UIBarButtonItem *)sender {
	self.cancelAction();
}

@end
