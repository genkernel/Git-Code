//
//  DARepoCtrl.h
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"
#import "DADiffCtrl.h"
#import "DAStatsCtrl.h"

typedef enum {
	DAStatsHeadlineMode,
	DAStatsHiddenMode,
	DAStatsFullscreenMode
} DAStatsContainerModes;

@interface DARepoCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate> {
	BOOL isBranchOverlayVisible;
	DAStatsContainerModes statsContainerMode;
	
	NSDictionary *_commitsOnDateSection;
	NSDictionary *_authorsOnDateSection;
	NSArray *_dateSections;
	
	NSMutableDictionary *_statsCommitsByAuthor;
	NSMutableDictionary *_statsCommitsByBranch;
	
	GTBranch *_currentBranch;
	NSMutableDictionary *_authors, *_branches;
	NSUInteger _statsCommitsCount;
	
	NSString *_statsCustomTitle, *_statsCustomHint;
	
	DAStatsCtrl *_statsCtrl;
}
@property (strong, nonatomic) GTRepository *currentRepo;
@property (nonatomic) BOOL shouldPull;

@property (strong, nonatomic) DAGitServer *repoServer;

@property (strong, nonatomic, readonly) NSMutableDictionary *authors, *branches;
// Format: author.name  =>  <NSArray of commits>
@property (strong, nonatomic, readonly) NSDictionary *statsCommitsByAuthor;
// Format: branch.name  =>  <NSArray of commits>
@property (strong, nonatomic, readonly) NSDictionary *statsCommitsByBranch;

@property (strong, nonatomic, readonly) NSDateFormatter *dateSectionTitleFormatter;

@property (strong, nonatomic) IBOutlet UIView *statsContainer;

@property (strong, nonatomic) IBOutlet UIView *mainContainer;
@property (strong, nonatomic) IBOutlet UITableView *commitsTable;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainContainerTop, *mainContainerHeight;

@property (strong, nonatomic) IBOutlet UIView *diffLoadingOverlay;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *diffLoadingIndicator;

@property (strong, nonatomic) IBOutlet UIView *branchCustomTitleContainer;
@property (strong, nonatomic) IBOutlet UILabel *branchCustomTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *branchCustomTitleButton;


@property (strong, nonatomic) IBOutlet UIView *pullingContainer;
@property (strong, nonatomic) IBOutlet UITextField *pullingField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *pullingIndicator;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pullingContainerTop;

@property (strong, nonatomic) IBOutlet UIView *branchOverlay, *branchCtrlContainer;
@property (strong, nonatomic) IBOutlet UIButton *revealBranchOverlayButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *branchOverlayLeft;

@property (strong, nonatomic) IBOutlet UIButton *grabButton;

@property (strong, nonatomic) IBOutlet UIView *weekendTitleView;
@property (strong, nonatomic) IBOutlet UILabel *statsTitleWeekdayLabel;
@property (strong, nonatomic) IBOutlet UILabel *statsTitleWeekendHintLabel;

@property (strong, nonatomic) IBOutlet UIButton *forgetButton;
@property (strong, nonatomic) IBOutlet UIView *statsCustomRightView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *statsSwitchModeButtons;

// Private. Category-visible methods.
- (void)reloadFilters;
- (void)reloadCommits;
- (void)addForgetButton;

- (void)presentDiffCtrlForCommit:(GTCommit *)commit;
@end
