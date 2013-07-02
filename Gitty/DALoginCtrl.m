//
//  DAViewController.m
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DALoginCtrl.h"
#import "DARepoCtrl.h"
#import "DAServerCtrl.h"
#import "DANewServerCtrl.h"

#import "DAGitServer+Creation.h"

static NSString *RepoSegue = @"RepoSegue";
static NSString *SettingsSegue = @"SettingsSegue";

@interface DALoginCtrl ()
@property (strong, nonatomic, readonly) DAGitServer *currentServer;

@property (strong, nonatomic, readonly) NSMutableArray *ctrls;
@property (weak, nonatomic, readonly) DAServerCtrl *currentCtrl;
@property (strong, nonatomic, readonly) DANewServerCtrl *createCtrl;
@end

@implementation DALoginCtrl {
	BOOL isRepoCloned;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:RepoSegue]) {
		assert([sender isKindOfClass:GTRepository.class]);
		
		DARepoCtrl *ctrl = segue.destinationViewController;
		ctrl.currentRepo = sender;
		ctrl.shouldPull = !isRepoCloned;
	} else if ([segue.identifier isEqualToString:SettingsSegue]) {
	} else {
		[super prepareForSegue:segue sender:sender];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	_ctrls = NSMutableArray.new;
	_createCtrl = [self newServerCreationCtrl];
	
	_currentServer = self.servers.list[0];
	
	self.serverDotsControl.numberOfPages = self.servers.list.count + 1;
	self.serverDotsControl.currentPage = 1;
	
	self.pager.looped = YES;
	self.pager.defaultPage = 1;
	[self.pager reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)testRepoWithUserString:(NSString *)repoName {
	BOOL existent = [self.git isLocalRepoExistent:repoName forServer:self.currentServer];
	isRepoCloned = !existent;
	
	if (existent) {
		GTRepository *repo = [self.git localRepoWithName:repoName forServer:self.currentServer];
		[self performSegueWithIdentifier:RepoSegue sender:repo];
		
		[self.currentCtrl resetProgress];
	} else {
		DAGitUser *user = nil;
		if (self.currentCtrl.isUsingCredentials) {
			user = [DAGitUser userWithName:self.currentCtrl.userNameField.text password:self.currentCtrl.userPasswordField.text];
		}
		
		[self cloneRemoteRepoWithName:repoName fromServer:self.currentServer authenticationUser:user];
	}
	
	[self.servers save];
}

- (DAServerCtrl *)newServerCtrl {
	DAServerCtrl *ctrl = DAServerCtrl.viewCtrl;
	
	[ctrl view];
	[ctrl.exploreButton addTarget:self action:@selector(exploreDidClick:) forControlEvents:UIControlEventTouchUpInside];
	
	return ctrl;
}

- (DANewServerCtrl *)newServerCreationCtrl {
	DANewServerCtrl *ctrl = DANewServerCtrl.viewCtrl;
	
	[ctrl view];
	[ctrl.createButton addTarget:self action:@selector(createDidClick:) forControlEvents:UIControlEventTouchUpInside];
	
	return ctrl;
}

#pragma mark PagerViewDataSource, PagerViewDelegate

- (NSUInteger)numberOfPages {
	return self.servers.list.count + 1;
}

- (PagerItemView *)pager:(PagerView *)pagerView pageAtIndex:(NSUInteger)index {
	BOOL isNewServerCreationCtrl = 0 == index;
	if (isNewServerCreationCtrl) {
		return (PagerItemView *)self.createCtrl.view;
	}
	
	// [0] - occupied by CreateNewServerCtrl.
	NSUInteger serverIndex = index - 1;
	
	DAServerCtrl *ctrl = nil;
	PagerItemView *view = [pagerView dequeueViewWithIdentifier:DAServerCtrl.className];
	if (view) {
		ctrl = self.ctrls[view.tag];
	} else {
		ctrl = [self newServerCtrl];
		[self.ctrls addObject:ctrl];
		
		ctrl.view.tag = self.ctrls.count - 1;
		view = (PagerItemView *)ctrl.view;
	}
	
	[ctrl loadServer:self.servers.list[serverIndex]];
	return view;
}

- (void)pager:(PagerView *)pagerView centerItemDidChange:(NSUInteger)index {
	self.serverDotsControl.currentPage = index;
	
	if (0 == index) {
		// CreateNewServerCtrl.
		return;
	}
	
	// [0] - occupied by CreateNewServerCtrl.
	NSUInteger serverIndex = index - 1;
	
	for (DAServerCtrl *ctrl in self.ctrls) {
		PagerItemView *view = (PagerItemView *)ctrl.view;
		if (view.datasourceIndex == index) {
			_currentCtrl = ctrl;
			break;
		}
	}
	
	_currentServer = self.servers.list[serverIndex];
	
	[Logger info:@"Current server (t:%d idx:%d): %@", pagerView.tag, index, self.currentServer];
}

#pragma mark PageControlDelegate

- (UIImage *)activeImageForIndex:(NSUInteger)index {
	return 0 == index ? [UIImage imageNamed:@"symbol-plus.png"] : nil;
}

- (UIImage *)inactiveImageForIndex:(NSUInteger)index {
	return 0 == index ? [UIImage imageNamed:@"symbol-plus_gray.png"] : nil;
}

#pragma mark Internals

- (void)cloneRemoteRepoWithName:(NSString *)repoName fromServer:(DAGitServer *)server authenticationUser:(DAGitUser *)user {
	DAServerCtrl *serverCtrl = self.currentCtrl;
	
	self.pager.userInteractionEnabled = NO;
	[serverCtrl setEditing:NO animated:YES];
	
	DAGitCloneDelegate *delegate = DAGitCloneDelegate.new;
	delegate.transferProgressBlock = ^(const git_transfer_progress *progress){
		if (0 == progress->total_objects) {
			[Logger warn:@"0 total_objects specified during repo cloning."];
			return;
		}
		CGFloat percent = (CGFloat)progress->received_objects / progress->total_objects;
		[Logger info:@"clone.transfer transter percent: %d", percent];
		
		[serverCtrl setProgress:percent];
	};
	delegate.checkoutProgressBlock = ^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps){
		// 'Bare' repo is not checked out.
		[Logger info:@"clone.checkout.checkout %d/%d", completedSteps, totalSteps];
	};
	delegate.finishBlock = ^(DAGitAction *action, NSError *err){
		self.pager.userInteractionEnabled = YES;
		[serverCtrl setEditing:YES animated:YES];
		
		[serverCtrl resetProgress];
		
		if (err) {
			NSString *title = NSLocalizedString(@"Error", nil);
			NSString *message = NSLocalizedString(err.localizedDescription, nil);
			
			[self.app showAlert:title message:message delegate:nil];
			return;
		}
		
		DAGitClone *clone = (DAGitClone *)action;
		[self performSegueWithIdentifier:RepoSegue sender:clone.clonedRepo];
	};
	
	DAGitClone *clone = [DAGitClone cloneRepoWithName:repoName fromServer:server];
	clone.authenticationUser = user;
	clone.delegate = delegate;
	
	[self.git request:clone];
}

#pragma mark Actions

- (void)exploreDidClick:(UIButton *)sender {
	[self.currentCtrl startProgressing];
	
	[self testRepoWithUserString:self.currentCtrl.repoField.text];
}

- (void)createDidClick:(UIButton *)sender {
	NSString *name = self.createCtrl.serverNameField.text;
	
	if (self.servers.namedList[name]) {
		[self showErrorAlert:@"Name is assigned to another Server already."];
		return;
	}
	
	NSString *url = self.createCtrl.serverUrlField.text;
	NSDictionary *info = @{ServerName: name,
						ServerGitBaseUrl: url,
						SaveDirectory: name,
						LogoIcon: @"",
						TransferProtocol: @"git://",
						SupportedProtocols: @[@"git://", @"https://", @"http://", @"ssh://", @"file://"]};
	
	DAGitServer *server = [DAGitServer serverWithDictionary:info];
	[self.servers addNewServer:server];
	
	NSString *message = [NSString stringWithFormat:@"'%@' has been created.", name];
	[self showInfoAlert:message];
	
	[self.createCtrl resetFields];
	
	self.serverDotsControl.numberOfPages = self.servers.list.count + 1;
	
	self.pager.defaultPage = [self.servers.list indexOfObject:server];
	[self.pager reloadData];
}

@end
