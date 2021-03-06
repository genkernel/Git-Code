//
//  DAViewController.m
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DALoginCtrl.h"
#import "DALoginCtrl+Internal.h"
#import "DALoginCtrl+Operations.h"

#import "DARepoCtrl.h"
#import "DAServerCtrl.h"
#import "DAServerCtrl+Animation.h"
#import "DANewServerCtrl.h"
#import "DARecentReposCtrl.h"
// Tips.
#import "DASshTipCtrl.h"
#import "DASwipeTipCtrl.h"
#import "DASupportTipCtrl.h"

#import "DASshInfoCtrl.h"
#import "DAFeedbackCtrl.h"

#import "DAGitServer+Creation.h"

@import ObjectiveGit;

static const NSUInteger MaximumServersCount = 10;

static NSString *RepoSegue = @"RepoSegue";
static NSString *SshInfoSegue = @"SshInfoSegue";
static NSString *SettingsSegue = @"SettingsSegue";
static NSString *FeedbackSegue = @"FeedbackSegue";

static NSString *LastSessionActivePageIndex = @"LastSessionActivePageIndex";

@interface DALoginCtrl ()
@property (strong, nonatomic, readonly) DAGitServer *currentServer;

@property (strong, nonatomic, readonly) NSMutableArray *ctrls;
@property (weak, nonatomic, readonly) DAServerCtrl *currentCtrl;
@property (strong, nonatomic, readonly) DANewServerCtrl *createCtrl;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@end

@implementation DALoginCtrl {
	BOOL isRepoCloned;
	NSUInteger deleteCurrentServerActionTag;
	NSUInteger deleteInvalidRepoActionTag;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:RepoSegue]) {
		
		DARepoCtrl *ctrl = segue.destinationViewController;
		ctrl.shouldPull = !isRepoCloned;
		
		NSDictionary *info = sender;
		ctrl.authUser = info[@"user"];
		ctrl.currentRepo = info[@"repo"];
		
		ctrl.repoServer = self.currentServer;
	} else if ([segue.identifier isEqualToString:SshInfoSegue]) {
	} else if ([segue.identifier isEqualToString:SettingsSegue]) {
	} else if ([segue.identifier isEqualToString:FeedbackSegue]) {
	} else {
		[super prepareForSegue:segue sender:sender];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Back", nil);
	
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
	
	self.deleteButton.hidden = lastActivePageIdx <= 2;
	
	self.serverDotsControl.numberOfPages = pagesCount;
	self.serverDotsControl.currentPage = lastActivePageIdx;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		self.pager.looped = YES;
		self.pager.defaultPage = lastActivePageIdx;
		[self.pager reloadData];
	});
	
	self.pager.minSwitchDistance = self.view.width / 3.;
	
	__weak DALoginCtrl *ref = self;
	[NSNotificationCenter.defaultCenter addObserverForName:DASSHKeysStateChanged object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
		for (DAServerCtrl *ctrl in ref.ctrls) {
			[ctrl reloadCurrentServer];
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[DAFlurry logScreenAppear:self.className];
	
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self logLoginAppearAction];
	
	if (!DASettings.currentUserSettings.didPresentSwipeToServerHint) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self presentSwipeToServerHint];
		});
	}
	
	if (self.repoCtrlDidFailToProcessRepoAsInvalid) {
		_repoCtrlDidFailToProcessRepoAsInvalid = NO;
		
		NSString *message = NSLocalizedString(@"Repository is invalid.\n\nDelete this repository from\nrecent repos list and\ntry to clone again.\n\n(Previous clone operation failed?)", nil);
		
#warning disabled
//		deleteInvalidRepoActionTag = [self showErrorMessage:message];
		[self showErrorMessage:message];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[DAFlurry logScreenDisappear:self.className];
}

- (NSString *)analyticsCurrentServerName {
	if (1 == self.serverDotsControl.currentPage) {
		return GitServerGithub;
	} else if (2 == self.serverDotsControl.currentPage) {
		return GitServerBitbucket;
	} else {
		return GitServerCustom;
	}
}

- (void)presentSwipeToServerHint {
	[AlertQueue.queue enqueueAlert:[CustomAlert alertPresentingCtrl:DASwipeTipCtrl.new animated:YES]];
	
	DASettings.currentUserSettings.didPresentSwipeToServerHint = YES;
}

- (void)deleteCurrentServer {
	self.view.userInteractionEnabled = NO;
	
	[self.pager navigateLeftAnimated:YES];
	
	self.pager.defaultPage = [self.servers.list indexOfObject:self.currentServer];
	
	[self deleteServer:self.currentServer];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(StandardAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.pager reloadData];
		
		self.view.userInteractionEnabled = YES;
	});
	
	self.serverDotsControl.numberOfPages = self.servers.list.count + 1;
	
	[DAFlurry logWorkflowAction:WorkflowActionServerRemoved];
}

- (DAGitServer *)createNewServerWithDictionary:(NSDictionary *)info {
	DAGitServer *server = [DAGitServer serverWithDictionary:info];
	[self.servers addNewServer:server];
	
	NSString *message = [NSString stringWithFormat:@"'%@' new server has been created.", info[ServerName]];
	[self showInfoMessage:message];
	
	[self.createCtrl resetFields];
	
	self.serverDotsControl.numberOfPages = self.servers.list.count + 1;
	
	self.pager.defaultPage = [self.servers.list indexOfObject:server] + 1;
	[self.pager reloadData];
	
	[DAFlurry logWorkflowAction:WorkflowActionCustomServerCreated];
	
	return server;
}

- (void)scrollToServer:(DAGitServer *)server animated:(BOOL)animated {
	if (self.currentServer == server) {
		return;
	}
	
	NSUInteger idx = [self.servers.list indexOfObject:server];
	
	if (idx == NSNotFound) {
		[LLog error:@"Failed to scroll to specified server. No such server found: %@", server];
		return;
	}
	
	[self.pager navigateToPage:idx + 1 animated:animated];
}

#pragma mark Workflow actions

- (void)logLoginAppearAction {
	static NSString *login = @"Login.Ctrl-Appear";
	
	int actionCounter = [DASettings.currentUserSettings doAction:login];
	if (3 == actionCounter) {
		
		double delayInSeconds = 1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			CustomAlert *alert = [CustomAlert alertPresentingCtrl:DASupportTipCtrl.viewCtrl animated:YES];
			[AlertQueue.queue enqueueAlert:alert];
		});
	}
}

- (void)logLoginAuthAction {
	static NSString *login = @"Login.Auth-Expand";
	
	int actionCounter = [DASettings.currentUserSettings doAction:login];
	if (1 == actionCounter || 5 == actionCounter || 50 == actionCounter) {
		
		BOOL isSshSupportedByServer = [DASshCredentials.manager hasSshKeypairSupportForServer:self.currentServer];
		if (isSshSupportedByServer) {
			return;
		}
		
		CustomAlert *alert = [CustomAlert alertPresentingCtrl:DASshTipCtrl.viewCtrl animated:YES];
		[AlertQueue.queue enqueueAlert:alert];
	}
}

#pragma mark Internals

- (NSDictionary *)infoDictWithRepo:(GTRepository *)repo user:(DAGitUser *)user {
	if (user) {
		return @{@"repo": repo, @"user": user};
	}
	return @{@"repo": repo};
}

- (void)exploreRepoWithPath:(NSString *)path {
	[self.currentCtrl startProgressing];
	
	self.currentCtrl.repoField.text = path;
	
	[self testRepoWithUserString:path];
}

- (void)testRepoWithUserString:(NSString *)repoName {
	BOOL existent = [self.git isLocalRepoExistent:repoName forServer:self.currentServer];
	isRepoCloned = !existent;
	
	DAGitUser *user = nil;
	if (self.currentCtrl.isUsingCredentials) {
		user = [DAGitUser userWithName:self.currentCtrl.userNameField.text password:self.currentCtrl.userPasswordField.text];
		
		[DAFlurry logWorkflowAction:WorkflowActionLoginUsingCredentials];
	}
	
	if (existent) {
		[DAFlurry logSuccessServer:self.analyticsCurrentServerName];
		
		GTRepository *repo = [self.git localRepoWithName:repoName forServer:self.currentServer];
		NSDictionary *info = [self infoDictWithRepo:repo user:user];
		
		[self performSegueWithIdentifier:RepoSegue sender:info];
		
		[self.currentCtrl resetProgress];
		
		[self.currentServer addOrUpdateRecentRepoWithRelativePath:repoName];
		self.currentServer.recentRepoPath = repoName;
		
		[self.servers save];
		
	} else {
		[self cloneRemoteRepoWithName:repoName fromServer:self.currentServer authenticationUser:user];
	}
}

- (void)cloneRemoteRepoWithName:(NSString *)repoName fromServer:(DAGitServer *)server authenticationUser:(DAGitUser *)user {
	DAServerCtrl *serverCtrl = self.currentCtrl;
	
	self.pager.userInteractionEnabled = NO;
	[serverCtrl setEditing:NO animated:YES];
	
	self.app.idleTimerDisabled = YES;
	
	DAGitCloneDelegate *delegate = DAGitCloneDelegate.new;
	delegate.transferProgressBlock = ^(const git_transfer_progress *progress){
		if (0 == progress->total_objects) {
			[LLog warn:@"0 total_objects specified during repo cloning."];
			return;
		}
		CGFloat percent = (CGFloat)progress->received_objects / progress->total_objects;
		[serverCtrl setProgress:percent];
	};
	delegate.checkoutProgressBlock = ^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps){
		// 'Bare' repo is not checked out.
		[LLog info:@"clone.checkout.checkout %d/%d", completedSteps, totalSteps];
	};
	delegate.finishBlock = ^(DAGitAction *action, NSError *err){
		self.pager.userInteractionEnabled = YES;
		[serverCtrl setEditing:YES animated:YES];
		
		self.app.idleTimerDisabled = NO;
		
		[serverCtrl resetProgress];
		
		if (err) {
			NSString *message = nil;
			
#warning disabled
//			if (git_error_code.GIT_EUSER == err.code) {
//				message = NSLocalizedString(@"Invalid user credentials specified.", nil);
//			} else {
			{
				NSError *underlyingErr = err.userInfo[NSUnderlyingErrorKey];
				
				if (underlyingErr) {
					message = NSLocalizedString(underlyingErr.localizedDescription, nil);
				} else {
					message = NSLocalizedString(err.localizedDescription, nil);
				}
			}
			
			[self showErrorMessage:message];
			
			[DAFlurry logGitAction:GitActionCloneFailed];
			[DAFlurry logInvalidServer:self.analyticsCurrentServerName];
			
			return;
		}
		
		[DAFlurry logGitAction:GitActionCloneSuccess];
		[DAFlurry logSuccessServer:self.analyticsCurrentServerName];
		
		DAGitClone *clone = (DAGitClone *)action;
		NSDictionary *info = [self infoDictWithRepo:clone.clonedRepo user:user];
		
		[self performSegueWithIdentifier:RepoSegue sender:info];
		
		[self.currentServer addOrUpdateRecentRepoWithRelativePath:repoName];
		self.currentServer.recentRepoPath = repoName;
		
		[self.servers save];
	};
	
	DAGitClone *clone = [DAGitClone cloneRepoWithName:repoName fromServer:server];
	clone.authenticationUser = user;
	clone.delegate = delegate;
	
	[self.git request:clone];
}

- (DAServerCtrl *)newServerCtrl {
	DAServerCtrl *ctrl = DAServerCtrl.viewCtrl;
	
	((PagerItemView *)ctrl.view).identifier = DAServerCtrl.className;
	
	[ctrl.loginButton addTarget:self action:@selector(loginDidClick:) forControlEvents:UIControlEventTouchUpInside];
	[ctrl.exploreButton addTarget:self action:@selector(exploreDidClick:) forControlEvents:UIControlEventTouchUpInside];
	[ctrl.recentReposButton addTarget:self action:@selector(recentReposDidClick) forControlEvents:UIControlEventTouchUpInside];
	
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
			NSString *message = NSLocalizedString(@"Maximum servers count of 10 reached", nil);
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
	
	self.deleteButton.hidden = index <= 2;
	
	if (0 == index) {
		// CreateNewServerCtrl.
		self.sshButton.hidden = YES;
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
	
	self.sshButton.hidden = [DASshCredentials.manager hasSshKeypairSupportForServer:self.currentServer];
	
//	[LLog info:@"Current server (t:%d idx:%d): %@", pagerView.tag, index, self.currentServer];
}

#pragma mark PageControlDelegate

- (UIImage *)activeImageForIndex:(NSUInteger)index {
	return 0 == index ? [UIImage imageNamed:@"symbol-plus.png"] : nil;
}

- (UIImage *)inactiveImageForIndex:(NSUInteger)index {
	return 0 == index ? [UIImage imageNamed:@"symbol-plus_gray.png"] : nil;
}

#pragma mark Actions

- (void)loginDidClick:(UIButton *)sender {
	[self.currentCtrl setCredentialsVisible:!self.currentCtrl.isUsingCredentials animated:YES];
	
	if (self.currentCtrl.isUsingCredentials) {
		[self logLoginAuthAction];
	}
}

- (void)exploreDidClick:(UIButton *)sender {
	[self exploreRepoWithPath:self.currentCtrl.repoField.text];
}

- (void)recentReposDidClick {
	DARecentReposCtrl *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:DARecentReposCtrl.className];
	
	ctrl.server = self.currentServer;
	ctrl.presentationOption = DASlideFromTopToBottomPresentation;
	
	__weak DALoginCtrl *ref = self;
	
	ctrl.cancelAction = ^{
		[ref dismissViewControllerAnimated:YES completion:nil];
	};
	ctrl.selectAction = ^(NSDictionary *repo){
		ref.currentCtrl.repoField.text = repo.relativePath;
		
		[ref dismissViewControllerAnimated:YES completion:nil];
	};
	
	[self presentViewController:ctrl animated:YES completion:nil];
}

- (void)createDidClick:(UIButton *)sender {
	NSString *name = self.createCtrl.serverNameField.text;
	
	if ([self.servers findServerByName:name]) {
		[self showErrorMessage:@"Server Name is in use already."];
		return;
	}
	
	NSString *url = self.createCtrl.serverUrlField.text;
	NSDictionary *info = @{ServerName: name,
						   ServerGitBaseUrl: url,
						   SaveDirectory: name,
						   LogoIcon: @"Git-Icon.png",
						   TransferProtocol: @"git://",
						   SupportedProtocols: @[@"https://", @"git://", @"http://"],
						   RecentRepoPath: @"",
						   RecentRepos: @{}};
	
	[self createNewServerWithDictionary:info];
}

- (IBAction)aboutClicked:(UIButton *)sender {
	DAFeedbackCtrl *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:DAFeedbackCtrl.className];
	ctrl.presentationOption = DASlideFromBottomToTopPresentation;
	
	[self presentViewController:ctrl animated:YES completion:nil];
}

- (IBAction)sshClicked:(UIButton *)sender {
	DASshInfoCtrl *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:DASshInfoCtrl.className];
	ctrl.presentationOption = DASlideFromBottomToTopPresentation;
	
	[self presentViewController:ctrl animated:YES completion:nil];
}

- (IBAction)deleteClicked:(UIButton *)sender {
	if (self.serverDotsControl.currentPage <= 2) {
		return;
	}
	
	NSString *title = NSLocalizedString(@"Delete server", nil);
	NSString *message = NSLocalizedString(@"Do you want to delete '%@' server\nand all its repos?", nil);
	
	message = [NSString stringWithFormat:message, self.currentServer.name];

#warning disabled
//	deleteCurrentServerActionTag = [self showYesNoMessage:message withTitle:title];
	[self showYesNoMessage:message withTitle:title];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == deleteCurrentServerActionTag) {
		if (0 == buttonIndex) {
			return;
		}
		
		[self deleteCurrentServer];
		
	} else if (alertView.tag == deleteInvalidRepoActionTag) {
		[self recentReposDidClick];
	}
}

@end
