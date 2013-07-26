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
@property (strong, nonatomic, readonly) NSMutableArray *repos;
@end

@implementation DARecentReposCtrl {
	NSUInteger forgetAllActionTag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.customNavigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.forgetButton];
	
	NSString *identifier = DARepoCell.className;
	UINib *nib = [UINib nibWithNibName:identifier bundle:nil];
	[self.reposTable registerNib:nib forCellReuseIdentifier:identifier];
	
	[self reloadReposFromCurrentServer];
}

- (void)reloadReposFromCurrentServer {
	_repos = [NSMutableArray arrayWithArray:self.server.reposByAccessTime];
	
	[self reloadControlsAccordingToCurrentRepos];
}

- (void)reloadControlsAccordingToCurrentRepos {
	self.customNavigationItem.rightBarButtonItem.enabled = self.repos.count > 0;
	
	BOOL shouldShowEmptyMessage = self.repos.count == 0;
	self.emptyLabel.hidden = !shouldShowEmptyMessage;
	self.reposTable.hidden = shouldShowEmptyMessage;
}

- (void)forgetAllRepos {
	[Logger info:@"Forgeting all repos."];
	
	for (NSDictionary *repo in self.repos) {
		[self forgetRepo:repo];
	}
	
	[self reloadReposFromCurrentServer];
	
	[self.reposTable reloadData];
	
	[self.servers save];
}

- (void)forgetRepo:(NSDictionary *)repo {
	[self.server removeRecentRepoByRelativePath:repo.relativePath];
	[self.git removeExistingRepo:repo.relativePath forServer:self.server];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *repo = self.repos[indexPath.row];
		
		[self forgetRepo:repo];
		[self.repos removeObject:repo];
		
		[self.reposTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		
		[self reloadControlsAccordingToCurrentRepos];
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == forgetAllActionTag) {
		if (0 == buttonIndex) {
			return;
		}
		
		[self forgetAllRepos];
	}
}

#pragma mark Actions

- (IBAction)cancelDidClicked:(UIBarButtonItem *)sender {
	self.cancelAction();
}

- (IBAction)forgetPressed:(UIButton *)button {
	NSString *title = NSLocalizedString(@"Forget all repos", nil);
	NSString *message = NSLocalizedString(@"This operation will forget all repos and delete its fetched data from your disk.\nContinue?", nil);
	
	forgetAllActionTag = [self showYesNoMessage:message withTitle:title];
}

@end
