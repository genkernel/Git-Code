//
//  DAReposListCtrl.m
//  Gitty
//
//  Created by kernel on 1/10/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DAReposListCtrl.h"
#import "DAQuickRepoCell.h"

@interface DAReposListCtrl ()
@property (strong, nonatomic, readonly) NSArray *repos;
@end

@implementation DAReposListCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Repos", nil);
	
	_repos = self.server.reposByAccessTime;
	
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.serversButton];
	
	NSString *identifier = DAQuickRepoCell.className;
	UINib *nib = [UINib nibWithNibName:identifier bundle:nil];
	[self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DAQuickRepoCell *cell = [tableView dequeueReusableCellWithIdentifier:DAQuickRepoCell.className];
	
	[cell loadRepo:self.repos[indexPath.row] active:(indexPath.row == 0)];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == 0) {
		self.dismissAction();
	} else {
		self.selectAction(self.repos[indexPath.row]);
	}
}

#pragma mark Actions

- (IBAction)serversButtonPressed:(UIButton *)sender {
	self.showServersAction();
}

@end
