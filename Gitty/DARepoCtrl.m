//
//  DARepoCtrl.m
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl.h"
#import "DARepoCtrl+Table.h"
#import "DARepoCtrl+Private.h"
#import "DARepoCtrl+Animation.h"
#import "DARepoCtrl+GitFetcher.h"

#import "DAStatsCtrl+Animation.h"

#import "DAReposListCtrl.h"
#import "DARevealStatsTipCtrl.h"

#import "DALoginCtrl+Internal.h"

static NSString *MasterBranchName = @"master";

static NSString *DiffSegue = @"DiffSegue";
static NSString *StatsSegue = @"StatsSegue";

static const CGFloat StatsContainerMinDraggingOffsetToSwitchState = 100.;

@interface DARepoCtrl ()
@property (strong, nonatomic, readonly) DAStatsCtrl *statsCtrl;
@property (strong, nonatomic, readonly) DAReposListCtrl *recentReposCtrl;

@property (strong, nonatomic, readonly) UIButton *statsSelectedModeButton;

@property (weak, nonatomic) IBOutlet UIView *branchStatsLoadingContainer;
@property (weak, nonatomic) IBOutlet UILabel *branchStatsInfoLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *branchStatsLoadingIndicator;
@end

@implementation DARepoCtrl {
	NSArray *_remoteBranches, *_tags;
	
	CGFloat statsContainerOffsetBeforeDragging;
	CGFloat branchContainerOffsetBeforeDragging;
}
@synthesize branches = _branches;
@synthesize currentBranch = _currentBranch;
@synthesize currentTag = _currentTag;
@synthesize statsCtrl = _statsCtrl;

// Category-defined ivars synthesized explicitly.
@synthesize remoteBranches = _remoteBranches;
@synthesize namedBranches;

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:DiffSegue]) {
		DADiffCtrl *ctrl = segue.destinationViewController;
		ctrl.diff = sender;
	} else if ([segue.identifier isEqualToString:StatsSegue]) {
		_statsCtrl = segue.destinationViewController;
	} else {
		[super prepareForSegue:segue sender:sender];
	}
}

- (id<UIViewControllerAnimatedTransitioning>)animatedTransitioningForOperation:(UINavigationControllerOperation)operation {
	return [AMWaveTransition transitionWithOperation:operation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.hidesBackButton = YES;
	
	self.pullingContainer.backgroundColor = self.navigationController.navigationBar.backgroundColor;
	
	_statsSelectedModeButton = self.statsSwitchModeButtons[0];
	
	[self setupCells];
	
	if (![self loadInitialData]) {
		DALoginCtrl *loginCtrl = (DALoginCtrl *)self.navigationController.viewControllers.firstObject;
		
		loginCtrl.repoCtrlDidFailToProcessRepoAsInvalid = YES;
		
		return;
	}
	
	[self loadRecentReposCtrl];
	
	[DAFlurry logProtocol:self.repoServer.transferProtocol];
	
	// FIXME: come up with better solution.
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LightningAnimationDuration * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		self.mainContainerHeight.constant = self.view.height - self.mainContainerTop.constant;
		[self.mainContainer.superview layoutIfNeeded];
	});
}

- (void)loadRecentReposCtrl {
	_recentReposCtrl = DAReposListCtrl.new;
	
	__weak typeof (self) ref = self;
	
	self.recentReposCtrl.server = self.repoServer;
	
	self.recentReposCtrl.dismissAction = ^{
		[ref dismissPresentedMenuAnimated:YES];
		
		[ref setPullingVisible:YES animated:YES];
		[ref pull];
	};
	self.recentReposCtrl.showServersAction = ^{
		[ref dismissPresentedMenuAnimated:YES];
		[ref.navigationController popViewControllerAnimated:NO];
	};
	self.recentReposCtrl.selectAction = ^(NSDictionary *anotherRepo) {
		
		NSString *repoName = anotherRepo.relativePath;
		
		[ref.repoServer addOrUpdateRecentRepoWithRelativePath:repoName];
		ref.repoServer.recentRepoPath = repoName;
		[ref.servers save];
		
		DARepoCtrl *ctrl = [ref.storyboard instantiateViewControllerWithIdentifier:DARepoCtrl.className];
		
		ctrl.shouldPull = YES;
		ctrl.authUser = ref.authUser;
		ctrl.repoServer = ref.repoServer;
		
		ctrl.currentRepo = [ref.git localRepoWithName:repoName forServer:ref.repoServer];
		
		[ref dismissPresentedMenuAnimated:YES];
		
		NSMutableArray *ctrls = ref.navigationController.viewControllers.mutableCopy;
		ctrls[ctrls.count - 1] = ctrl;
		
		[ref.navigationController setViewControllers:ctrls animated:NO];
	};
}

- (BOOL)loadInitialData {
	_stats = [DAGitStats statsForRepository:self.currentRepo];
	
	_branches = NSMutableDictionary.new;
	
	[self reloadFilters];
	
	if (![self reloadCommitsTable]) {
		return NO;
	}
	
	if (!self.shouldPull) {
		[self loadStats];
	} else {
		[self pull];
	}
	
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[DAFlurry logScreenAppear:self.className];
	
	self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[DAFlurry logScreenDisappear:self.className];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	DALoginCtrl *loginCtrl = (DALoginCtrl *)self.navigationController.viewControllers.firstObject;
	if (loginCtrl.repoCtrlDidFailToProcessRepoAsInvalid) {
		[self.navigationController popViewControllerAnimated:YES];
		
		return;
	}
	
	if (self.selectedCommitIndexPath) {
		[self.commitsTable deselectRowAtIndexPath:self.selectedCommitIndexPath animated:animated];
		
		_selectedCommitIndexPath = nil;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self setDiffLoadingOverlayVisible:NO animated:NO];
}

- (void)addBranchesButton {
	self.navigationItem.titleView = self.branchCustomTitleContainer;
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.branchesButton];
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.reposButton];
}

- (void)reloadFilters {
	[self updateTagsFilter];
	[self updateBranchesFilter];
}

- (void)updateTagsFilter {
	NSError *err = nil;
	
	_tags = [self.currentRepo allTagsWithError:&err];
	
	[Logger info:@"%d Tags loaded.", self.tags.count];
}

- (void)updateBranchesFilter {
	NSError *err = nil;
	
	_remoteBranches = [self.currentRepo remoteBranchesWithError:&err];
	
	[Logger info:@"%d Branches loaded.", self.remoteBranches.count];
	
	BOOL isPresentingTag = nil != self.currentTag;
	if (isPresentingTag) {
		return;
	}
	
	[self loadDefaultBranch];
}

- (void)loadDefaultBranch {
	NSDictionary *repo = self.repoServer.activeRepo;
	
	GTBranch *defaultBranch = nil;
	NSString *recentBranchName = repo.activeBranchName ? repo.activeBranchName : MasterBranchName;
	
	NSMutableDictionary *branches = [NSMutableDictionary dictionaryWithCapacity:self.remoteBranches.count];
	for (GTBranch *branch in self.remoteBranches) {
		NSString *name = branch.shortName;
		branches[name] = branch;
		
		if ([name isEqualToString:recentBranchName]) {
			defaultBranch = branch;
			break;
		}
	}
	
	// Fallback to master.
	if (!defaultBranch) {
		defaultBranch = branches[MasterBranchName];
	}
	
	if (!defaultBranch) {
		defaultBranch = self.remoteBranches.anyObject;
	}
	
	[self selectBranch:defaultBranch];
}

- (BOOL)selectTag:(GTTag *)tag {
	if (!tag || self.currentTag == tag) {
		return NO;
	}
	
	_currentTag = tag;
	_currentBranch = nil;
	
	self.title = tag.name;
	self.branchCustomTitleLabel.text = tag.name;
	
	return YES;
}

- (BOOL)selectBranch:(GTBranch *)branch {
	if (!branch || self.currentBranch == branch) {
		return NO;
	}
	
	_currentTag = nil;
	_currentBranch = branch;
	
	
	[self.repoServer addOrUpdateRecentRepoWithRelativePath:self.repoServer.recentRepoPath activeBranchName:branch.shortName];
	[self.servers save];
	
	self.title = branch.shortName;
	self.branchCustomTitleLabel.text = branch.shortName;
	
	return YES;
}

- (BOOL)reloadCommitsTable {
	NSString *message = nil;
	DABranchWalk *walk = nil;
	
	if (self.currentBranch) {
		message = NSLocalizedString(@"Loading '%@' branch ...", nil);
		message = [NSString stringWithFormat:message, self.currentBranch.shortName];
		
		walk = [DABranchWalk walkForBranch:self.currentBranch];
	} else if (self.currentTag) {
		message = NSLocalizedString(@"Loading '%@' tag ...", nil);
		message = [NSString stringWithFormat:message, self.currentTag.name];
		
		walk = [DABranchWalk walkForTag:self.currentTag];
	} else {
		return NO;
	}
	
	self.branchStatsInfoLabel.text = message;
	
	self.commitsTable.hidden = YES;
	
	[self.branchStatsLoadingIndicator startAnimating];
	self.branchStatsLoadingContainer.hidden = NO;
	
	
	[self.stats performAsyncOperation:walk completionHandler:^{
		self.commitsTable.hidden = NO;
		[self.commitsTable reloadData];
		
		[self.branchStatsLoadingIndicator stopAnimating];
		self.branchStatsLoadingContainer.hidden = YES;
	}];
	
	_currentStats = walk;
	
	return YES;
}

- (void)presentDiffCtrlForCommit:(GTCommit *)commit {
	if (!commit.isLargeCommit) {
		DADiffCtrlDataSource *diff = [DADiffCtrlDataSource loadDiffForCommit:commit inRepo:self.currentRepo];
		
		[self performSegueWithIdentifier:DiffSegue sender:diff];
		return;
	}
	
	[UIView animateWithDuration:StandardAnimationDuration animations:^{
		[self setDiffLoadingOverlayVisible:YES animated:NO];
	}completion:^(BOOL finished) {
		[self prepareDiffForCommit:commit];
	}];
}

- (void)prepareDiffForCommit:(GTCommit *)commit {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		DADiffCtrlDataSource *diff = [DADiffCtrlDataSource loadDiffForCommit:commit inRepo:self.currentRepo];
		
		[DAFlurry logGitAction:GitActionDiff];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSegueWithIdentifier:DiffSegue sender:diff];
		});
	});
}

- (void)presentRevealStatsHint {
	[AlertQueue.queue enqueueAlert:[CustomAlert alertPresentingCtrl:DARevealStatsTipCtrl.new animated:YES]];
	
	DASettings.currentUserSettings.didPresentRevealStatsHint = YES;
}

#pragma mark Actions

- (IBAction)leftOptionPressed:(UIButton *)sender {
	if (self.isMenuPresented) {
		[self dismissPresentedMenuAnimated:YES];
	} else {
		[self presentMenuCtrl:self.recentReposCtrl animated:YES animationOption:DASlideFromLeftToRightPresentation];
	}
}

- (IBAction)rightOptionPressed:(UIButton *)button {
	DABranchPickerCtrl *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:DABranchPickerCtrl.className];
	ctrl.presentationOption = DASlideFromRightToLeftPresentation;
	{
		ctrl.tags = self.tags;
		ctrl.branches = self.remoteBranches;
		
		ctrl.currentTag = self.currentTag;
		ctrl.currentBranch = self.currentBranch;
	}
	
	[ctrl loadItemsWithoutFilter];
	
	__weak DARepoCtrl *ref = self;
	
	ctrl.tagSelectedAction = ^(GTTag *selectedTag){
		[ref dismissViewControllerAnimated:YES completion:nil];
		
		BOOL changed = [ref selectTag:selectedTag];
		if (changed) {
			[ref reloadCommitsTable];
			
			[DAFlurry logWorkflowAction:WorkflowActionTagSwitched];
		}
	};
	ctrl.branchSelectedAction = ^(GTBranch *selectedBranch){
		[ref dismissViewControllerAnimated:YES completion:nil];
		
		BOOL changed = [ref selectBranch:selectedBranch];
		if (changed) {
			[ref reloadCommitsTable];
			
			[DAFlurry logWorkflowAction:WorkflowActionBranchSwitched];
		}
	};
	ctrl.cancelAction = ^{
		[ref dismissViewControllerAnimated:YES completion:nil];
	};
	
	[self presentViewController:ctrl animated:YES completion:nil];
}

- (IBAction)statsModeChanged:(UIButton *)sender {
	self.statsSelectedModeButton.enabled = YES;
	_statsSelectedModeButton = sender;
	self.statsSelectedModeButton.enabled = NO;
	
	[self.statsCtrl toggleCommitsTablesAnimated:YES];
}

- (IBAction)statsDidClick:(UIButton *)sender {
	statsContainerOffsetBeforeDragging = .0;
	
	[self toggleStatsContainerMode];
}

- (void)toggleStatsContainerMode {
	DAStatsContainerModes mode = DAStatsFullscreenMode == statsContainerMode ? DAStatsHiddenMode : DAStatsFullscreenMode;
	[self setStatsContainerMode:mode animated:YES];
}

- (IBAction)statsDidDrag:(UIPanGestureRecognizer *)gr {
	CGPoint p = [gr translationInView:self.view];
	
	if (UIGestureRecognizerStateBegan == gr.state) {
		statsContainerOffsetBeforeDragging = self.mainContainerTop.constant;
	} else if (UIGestureRecognizerStateChanged == gr.state) {
		CGFloat y = statsContainerOffsetBeforeDragging + p.y;
		
		if (y >= .0 && y <= self.view.height) {
			self.mainContainerTop.constant = y;
		}
	} else if (UIGestureRecognizerStateEnded == gr.state) {
		if (DAStatsHeadlineMode == statsContainerMode) {
			statsContainerOffsetBeforeDragging = .0;
			
			DAStatsContainerModes mode = p.y > .0 ? DAStatsFullscreenMode : DAStatsHiddenMode;
			[self setStatsContainerMode:mode animated:YES];
			
			return;
		}
		
		CGFloat offset = fabsf(p.y);
		
		if (offset >= StatsContainerMinDraggingOffsetToSwitchState) {
			[self toggleStatsContainerMode];
		} else {
			// Decelerate back to original position (before dragging).
			self.mainContainerTop.constant = statsContainerOffsetBeforeDragging;
			
			[UIView animateWithDuration:StandardAnimationDuration animations:^{
				[self.mainContainer.superview layoutIfNeeded];
			}];
		}
	}
}
// hi
/*
- (void)toggleBranchOverlayMode {
	[self setBranchOverlayVisible:!isBranchOverlayVisible animated:YES];
}*/

#pragma mark AMWaveTransitioning

- (NSArray *)visibleCells {
	[Logger info:@"animating cells: %d", self.commitsTable.visibleCells.count];
	
	return self.commitsTable.visibleCells;
}

@end
