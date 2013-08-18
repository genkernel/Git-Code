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
#import "DARepoCtrl+StatsLoader.h"

#import "DAStatsCtrl+Animation.h"


static NSString *MasterBranchName = @"master";

static NSString *DiffSegue = @"DiffSegue";
static NSString *StatsSegue = @"StatsSegue";
static NSString *BranchPickerSegue = @"BranchPickerSegue";

static const CGFloat StatsContainerMinDraggingOffsetToSwitchState = 100.;
static const CGFloat BranchOverlyMinDraggingOffsetToSwitchState = 100.;


@interface DARepoCtrl ()
@property (strong, nonatomic, readonly) DAStatsCtrl *statsCtrl;
@property (strong, nonatomic, readonly) UIButton *statsSelectedModeButton;
@end


@implementation DARepoCtrl {
	NSUInteger forgetActionTag;
	CGFloat statsContainerOffsetBeforeDragging;
	CGFloat branchContainerOffsetBeforeDragging;
	NSArray *_remoteBranches, *_tags;
}
@synthesize statsCommitsCount = _statsCommitsCount;
@synthesize branches = _branches;
@synthesize currentBranch = _currentBranch, currentTag = _currentTag;
@synthesize statsCtrl = _statsCtrl;
@synthesize statsCommitsByAuthor = _statsCommitsByAuthor;
@synthesize statsCommitsByBranch = _statsCommitsByBranch;
// Category-defined ivars synthesized explicitly.
@synthesize remoteBranches = _remoteBranches;
@synthesize namedBranches;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:BranchPickerSegue]) {
		_branchPickerCtrl = segue.destinationViewController;
		
		__weak DARepoCtrl *ref = self;
		self.branchPickerCtrl.tagSelectedAction = ^(GTTag *selectedTag){
			[ref setBranchOverlayVisible:NO animated:YES];
			
			BOOL changed = [ref selectTag:selectedTag];
			if (changed) {
				[ref reloadCommitsAndOptionallyTable:YES];
				
				[DAFlurry logWorkflowAction:WorkflowActionTagSwitched];
			}
		};
		self.branchPickerCtrl.branchSelectedAction = ^(GTBranch *selectedBranch){
			[ref setBranchOverlayVisible:NO animated:YES];
			
			BOOL changed = [ref selectBranch:selectedBranch];
			if (changed) {
				[ref reloadCommitsAndOptionallyTable:YES];
				
				[DAFlurry logWorkflowAction:WorkflowActionBranchSwitched];
			}
		};
		self.branchPickerCtrl.cancelAction = ^{
			[ref setBranchOverlayVisible:NO animated:YES];
		};
	} else if ([segue.identifier isEqualToString:DiffSegue]) {
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
	
	UIImage *img = [UIImage imageNamed:@"branch-selector.png"];
	img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, img.size.height - 100, 0)];
	[self.revealBranchOverlayButton setBackgroundImage:img forState:UIControlStateNormal];
	
	_statsSelectedModeButton = self.statsSwitchModeButtons[0];
	
	[self setupCells];
	
	[self loadInitialData];
	
	// FIXME: come up with better solution.
	dispatch_async(dispatch_get_main_queue(), ^{
		self.mainContainerHeight.constant = self.view.height - self.mainContainerTop.constant;
		[self.mainContainer.superview layoutIfNeeded];
	});
	
	[DAFlurry logProtocol:self.repoServer.transferProtocol];
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
	
	// Initial loading. Required as of long-time pulling + open via swipe case (so list is not empty).
	self.branchPickerCtrl.tags = self.tags;
	self.branchPickerCtrl.branches = self.remoteBranches;
	[self.branchPickerCtrl loadItemsWithoutFilter];
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

- (void)addForgetButton {
	self.navigationItem.titleView = self.branchCustomTitleContainer;
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:self.forgetButton];
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
	
	if (!defaultBranch) {
		defaultBranch = [self.currentRepo currentBranchWithError:nil];
	}
	
	// Fallback to master.
	if (!defaultBranch) {
		defaultBranch = branches[MasterBranchName];
		if (!defaultBranch) {
			defaultBranch = self.remoteBranches.anyObject;
		}
	}
	[self selectBranch:defaultBranch];
}

- (BOOL)selectTag:(GTTag *)tag {
	if (!tag || self.currentTag == tag) {
		return NO;
	}
	
	_currentTag = tag;
	_currentBranch = nil;
	
	self.branchPickerCtrl.currentTag = tag;
	self.branchPickerCtrl.currentBranch = nil;
	
	self.branchCustomTitleLabel.text = tag.name;
	
	return YES;
}

- (BOOL)selectBranch:(GTBranch *)branch {
	if (!branch || self.currentBranch == branch) {
		return NO;
	}
	
	_currentTag = nil;
	_currentBranch = branch;
	
	self.branchPickerCtrl.currentTag = nil;
	self.branchPickerCtrl.currentBranch = branch;
	
	self.repoServer.recentBranchName = branch.shortName;
	[self.servers save];
	
	self.branchCustomTitleLabel.text = branch.shortName;
	
	return YES;
}

- (void)reloadCommitsAndOptionallyTable:(BOOL)shoudReloadTable {
	DABranchWalk *walk = [DABranchWalk walkForBranch:self.currentBranch];
	
	[self.stats performSyncOperation:walk];
	
	_currentBranchStats = walk;
	
	if (shoudReloadTable) {
		[self.commitsTable reloadData];
	}
}

- (void)forgetRepo {
	[self.navigationController popViewControllerAnimated:YES];
	
	[self.git removeExistingRepo:self.repoServer.recentRepoPath forServer:self.repoServer];
	
	[DAFlurry logWorkflowAction:WorkflowActionRepoForgotten];
}

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

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == forgetActionTag) {
		
		if (1 == buttonIndex) {
			[self forgetRepo];
		}
	}
}

#pragma mark Actions

- (IBAction)revealBranchPressed:(UIButton *)sender {
	BOOL shouldRevealOverlay = !isBranchOverlayVisible;
	if (shouldRevealOverlay) {
		// Reload as new branches were pulled in (possibly).
		self.branchPickerCtrl.tags = self.tags;
		self.branchPickerCtrl.branches = self.remoteBranches;
		
		[self.branchPickerCtrl resetUI];
	}
	
	[self setBranchOverlayVisible:shouldRevealOverlay animated:YES];
	
	[DAFlurry logWorkflowAction:WorkflowActionBranchListTouch];
}

- (IBAction)forgetPressed:(UIButton *)button {
	NSString *title = NSLocalizedString(@"Forget repo", nil);
	NSString *message = NSLocalizedString(@"Forgetting this repo will delete all its fetched data from disk.", nil);
	
	forgetActionTag = [self showYesNoMessage:message withTitle:title];
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

- (void)toggleBranchOverlayMode {
	[self setBranchOverlayVisible:!isBranchOverlayVisible animated:YES];
}

- (IBAction)branchDidDrag:(UIPanGestureRecognizer *)gr {
	CGPoint p = [gr translationInView:self.view];
	
	if (UIGestureRecognizerStateBegan == gr.state) {
		branchContainerOffsetBeforeDragging = self.branchOverlayLeft.constant;
		
	} else if (UIGestureRecognizerStateChanged == gr.state) {
		CGFloat x = branchContainerOffsetBeforeDragging + p.x;
		
		if (x >= .0 && x < self.view.width) {
			self.branchOverlayLeft.constant = x;
		}
		
	} else if (UIGestureRecognizerStateEnded == gr.state) {
		CGFloat offset = fabsf(p.x);
		
		if (offset >= BranchOverlyMinDraggingOffsetToSwitchState) {
			[self toggleBranchOverlayMode];
			[DAFlurry logWorkflowAction:WorkflowActionBranchListDrag];
		} else {
			// Decelerate back to original position (before dragging).
			self.branchOverlayLeft.constant = branchContainerOffsetBeforeDragging;
			
			[UIView animateWithDuration:StandartAnimationDuration animations:^{
				[self.branchOverlay.superview layoutIfNeeded];
			}];
		}
	}
}

@end
