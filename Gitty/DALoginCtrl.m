//
//  DAViewController.m
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DALoginCtrl.h"
#import "DARepoCtrl.h"

static NSString *RepoSegue = @"RepoSegue";

@interface DALoginCtrl ()
@property (strong, nonatomic, readonly) DAGitServer *currentServer;
@end

@implementation DALoginCtrl

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:RepoSegue]) {
		assert([sender isKindOfClass:GTRepository.class]);
		
		DARepoCtrl *ctrl = segue.destinationViewController;
		ctrl.currentRepo = sender;
	} else {
		[super prepareForSegue:segue sender:sender];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_currentServer = self.servers.list[0];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)testRepoWithUserString:(NSString *)repoName {
	BOOL existent = [self.git isLocalRepoExistent:repoName forServer:self.currentServer];
	if (existent) {
		GTRepository *repo = [self.git localRepoWithName:repoName forServer:self.currentServer];
		[self performSegueWithIdentifier:RepoSegue sender:repo];
	} else {
		[self cloneRemoteRepoWithName:repoName fromServer:self.currentServer];
	}
}

- (IBAction)explore:(UIButton *)sender {
	[self testRepoWithUserString:self.repoField.text];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9a-zA-Z/-]*"];
	return [predicate evaluateWithObject:string];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField.text.length > 0) {
		[self testRepoWithUserString:textField.text];
	}
	
	return YES;
}

#pragma mark Internals

- (void)cloneRemoteRepoWithName:(NSString *)repoName fromServer:(DAGitServer *)server {
	self.repoField.enabled = NO;
	
	DAGitCloneDelegate *delegate = DAGitCloneDelegate.new;
	delegate.transferProgressBlock = ^(const git_transfer_progress *progress){
		if (0 == progress->total_objects) {
			[Logger warn:@"0 total_objects specified during repo cloning."];
			return;
		}
		unsigned int percent = progress->received_objects * 100 / progress->total_objects;
		[Logger info:@"clone.transfer transter percent: %d", percent];
	};
	delegate.checkoutProgressBlock = ^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps){
		[Logger info:@"clone.checkout.checkout %d/%d", completedSteps, totalSteps];
	};
	delegate.finishBlock = ^(DAGitAction *action, NSError *err){
		self.repoField.enabled = YES;
		
		if (err) {
			NSString *title = NSLocalizedString(@"Error", nil);
			NSString *message = NSLocalizedString(@"Error", nil);
			
			[self.app showAlert:title message:message delegate:nil];
			return;
		}
		
		DAGitClone *clone = (DAGitClone *)action;
		[self performSegueWithIdentifier:RepoSegue sender:clone.clonedRepo];
	};
	
	DAGitClone *clone = [DAGitClone cloneRepoWithName:repoName fromServer:self.currentServer];
	clone.delegate = delegate;
	
	[self.git request:clone];
}

@end
