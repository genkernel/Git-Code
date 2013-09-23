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


static NSString *MasterBranchName = @"master";

static NSString *DiffSegue = @"DiffSegue";
static NSString *StatsSegue = @"StatsSegue";

static const CGFloat StatsContainerMinDraggingOffsetToSwitchState = 100.;
static const CGFloat BranchOverlyMinDraggingOffsetToSwitchState = 100.;


@interface DARepoCtrl ()
@property (strong, nonatomic, readonly) DAStatsCtrl *statsCtrl;
@property (strong, nonatomic, readonly) UIButton *statsSelectedModeButton;
@end


@implementation DARepoCtrl {
	CGFloat statsContainerOffsetBeforeDragging;
	CGFloat branchContainerOffsetBeforeDragging;
	NSArray *_remoteBranches, *_tags;
}
@synthesize branches = _branches;
@synthesize currentBranch = _currentBranch, currentTag = _currentTag;
@synthesize statsCtrl = _statsCtrl;
// Category-defined ivars synthesized explicitly.
@synthesize remoteBranches = _remoteBranches;
@synthesize namedBranches;

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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_statsSelectedModeButton = self.statsSwitchModeButtons[0];
	
	[self setupCells];
	
	[self loadInitialData];
	
	[DAFlurry logProtocol:self.repoServer.transferProtocol];
	
	//
	// FIXME: come up with better solution.
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LightningAnimationDuration * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		self.mainContainerHeight.constant = self.view.height - self.mainContainerTop.constant;
		[self.mainContainer.superview layoutIfNeeded];
	});
}

- (void)loadInitialData {
	_stats = [DAGitStats statsForRepository:self.currentRepo];
	
	_branches = NSMutableDictionary.new;
	
	[self reloadFilters];
	[self reloadCommitsAndOptionallyTable:NO];
	
	if (!self.shouldPull) {
		[self loadStats];
	} else {
		[self pull];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[DAFlurry logScreenAppear:self.className];
	
	[self.navigationController setNavigationBarHidden:isNavBarHiddenByThisCtrl animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[DAFlurry logScreenDisappear:self.className];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
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
	GTBranch *defaultBranch = nil;
	NSString *recentBranchName = self.repoServer.recentBranchName;
	
	NSMutableDictionary *branches = [NSMutableDictionary dictionaryWithCapacity:self.remoteBranches.count];
	for (GTBranch *branch in self.remoteBranches) {
		NSString *name = branch.shortName;
		branches[name] = branch;
		
		if ([name isEqualToString:recentBranchName]) {
			defaultBranch = branch;
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
	
	self.repoServer.recentBranchName = branch.shortName;
	[self.servers save];
	
	self.title = branch.shortName;
	self.branchCustomTitleLabel.text = branch.shortName;
	
	return YES;
}

- (void)reloadCommitsAndOptionallyTable:(BOOL)shoudReloadTable {
	DABranchWalk *walk = nil;
	
	if (self.currentBranch) {
		walk = [DABranchWalk walkForBranch:self.currentBranch];
	} else {
		walk = [DABranchWalk walkForTag:self.currentTag];
	}
	
	[self.stats performSyncOperation:walk];
	
	_currentStats = walk;
	
	if (shoudReloadTable) {
		[self.commitsTable reloadData];
	}
}
/*
- (void)forgetRepo {
	[self.navigationController popViewControllerAnimated:YES];
	
	[self.git removeExistingRepo:self.repoServer.recentRepoPath forServer:self.repoServer];
	
	[DAFlurry logWorkflowAction:WorkflowActionRepoForgotten];
}*/

- (void)presentDiffCtrlForCommit:(GTCommit *)commit {
	if (!commit.isLargeCommit) {
		DADiffCtrlDataSource *diff = [DADiffCtrlDataSource loadDiffForCommit:commit inRepo:self.currentRepo];
		
		[self performSegueWithIdentifier:DiffSegue sender:diff];
		return;
	}
	
	[UIView animateWithDuration:StandartAnimationDuration animations:^{
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

#pragma mark Actions

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
	
//	[self.branchPickerCtrl resetUI];
	
	__weak DARepoCtrl *ref = self;
	
	ctrl.tagSelectedAction = ^(GTTag *selectedTag){
		[ref dismissViewControllerAnimated:YES completion:nil];
		
		BOOL changed = [ref selectTag:selectedTag];
		if (changed) {
			[ref reloadCommitsAndOptionallyTable:YES];
			
			[DAFlurry logWorkflowAction:WorkflowActionTagSwitched];
		}
	};
	ctrl.branchSelectedAction = ^(GTBranch *selectedBranch){
		[ref dismissViewControllerAnimated:YES completion:nil];
		
		BOOL changed = [ref selectBranch:selectedBranch];
		if (changed) {
			[ref reloadCommitsAndOptionallyTable:YES];
			
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
			
			[UIView animateWithDuration:StandartAnimationDuration animations:^{
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

@end
