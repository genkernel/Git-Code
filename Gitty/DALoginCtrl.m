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

static const NSUInteger MaximumServersCount = 20;

static NSString *RepoSegue = @"RepoSegue";
static NSString *SettingsSegue = @"SettingsSegue";

static NSString *LastSessionActivePageIndex = @"LastSessionActivePageIndex";

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
		
		ctrl.repoServer = self.currentServer;
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
	
	const NSUInteger pagesCount = self.servers.list.count + 1;
	
	NSNumber *index = [[NSUserDefaults standardUserDefaults] objectForKey:LastSessionActivePageIndex];
	NSUInteger lastActivePageIdx = index ? index.unsignedIntegerValue : 1;
	
	if (lastActivePageIdx >= pagesCount) {
		lastActivePageIdx = 1;
	}
	
	BOOL isCreateNewServerDefaultPage = 0 == lastActivePageIdx;
	if (!isCreateNewServerDefaultPage) {
		_currentServer = self.servers.list[lastActivePageIdx - 1];
	}
	
	self.serverDotsControl.numberOfPages = pagesCount;
	self.serverDotsControl.currentPage = lastActivePageIdx;
	
	self.pager.looped = YES;
	self.pager.defaultPage = lastActivePageIdx;
	[self.pager reloadData];
	
	self.pager.minSwitchDistance = self.view.width / 3.;
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
		
		self.currentServer.recentRepoPath = repoName;
		[self.servers save];
	} else {
		DAGitUser *user = nil;
		if (self.currentCtrl.isUsingCredentials) {
			user = [DAGitUser userWithName:self.currentCtrl.userNameField.text password:self.currentCtrl.userPasswordField.text];
		}
		
		[self cloneRemoteRepoWithName:repoName fromServer:self.currentServer authenticationUser:user];
	}
}

- (DAServerCtrl *)newServerCtrl {
	DAServerCtrl *ctrl = DAServerCtrl.viewCtrl;
	
	((PagerItemView *)ctrl.view).identifier = DAServerCtrl.className;
	[ctrl.exploreButton addTarget:self action:@selector(exploreDidClick:) forControlEvents:UIControlEventTouchUpInside];
	
	return ctrl;
}

- (DANewServerCtrl *)newServerCreationCtrl {
	DANewServerCtrl *ctrl = DANewServerCtrl.viewCtrl;
	
	((PagerItemView *)ctrl.view).identifier = DANewServerCtrl.className;
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
		if (self.servers.list.count >= MaximumServersCount) {
			NSString *message = NSLocalizedString(@"Maximum servers count reached (20)", nil);
			[self.createCtrl disableFeatureWithNotice:message];
		}
		
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
	
	[[NSUserDefaults standardUserDefaults] setValue:@(index) forKey:LastSessionActivePageIndex];
	
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
		
		self.currentServer.recentRepoPath = repoName;
		[self.servers save];
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
		[self showErrorMessage:@"Server Name is in use already."];
		return;
	}
	
	NSString *url = self.createCtrl.serverUrlField.text;
	NSDictionary *info = @{ServerName: name,
						ServerGitBaseUrl: url,
						SaveDirectory: name,
						LogoIcon: @"Git-Icon.png",
						TransferProtocol: @"git://",
						SupportedProtocols: @[@"git://", @"https://", @"http://", @"file://"],
						RecentRepoPath: @""};
	
	DAGitServer *server = [DAGitServer serverWithDictionary:info];
	[self.servers addNewServer:server];
	
	NSString *message = [NSString stringWithFormat:@"'%@' has been created.", name];
	[self showInfoMessage:message];
	
	[self.createCtrl resetFields];
	
	self.serverDotsControl.numberOfPages = self.servers.list.count + 1;
	
	self.pager.defaultPage = [self.servers.list indexOfObject:server] + 1;
	[self.pager reloadData];
}

@end
