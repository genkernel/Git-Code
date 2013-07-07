//
//  DARepoCtrl.h
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

typedef enum {
	DAStatsHeadlineMode,
	DAStatsHiddenMode,
	DAStatsFullscreenMode
} DAStatsContainerModes;

@interface DARepoCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate> {
	BOOL isBranchOverlayVisible;
//	BOOL isStatsHeadlineVisible, isStatsContainerVisible;
	DAStatsContainerModes statsContainerMode;
	
	NSDictionary *_commitsOnDateSection;
	NSDictionary *_authorsOnDateSection;
	NSArray *_dateSections;
}
@property (strong, nonatomic) GTRepository *currentRepo;
@property (nonatomic) BOOL shouldPull;

@property (strong, nonatomic) DAGitServer *repoServer;

@property (strong, nonatomic, readonly) NSDateFormatter *dateSectionTitleFormatter;

@property (strong, nonatomic) IBOutlet UIView *statsContainer, *statsHeaderContainer;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *statsHeadlineLabel;

@property (strong, nonatomic) IBOutlet UIView *mainContainer;
@property (strong, nonatomic) IBOutlet UIView *headerContainer;
@property (strong, nonatomic) IBOutlet UIView *commitsContainer;
@property (strong, nonatomic) IBOutlet UITableView *commitsTable;

@property (strong, nonatomic) IBOutlet UIButton *currentBranchButton;

@property (strong, nonatomic) IBOutlet UIView *grayOverlay;
@property (strong, nonatomic) IBOutlet UIView *diffLoadingOverlay;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *diffLoadingIndicator;

@property (strong, nonatomic) IBOutlet UITextField *pullingField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *pullingIndicator;

@property (strong, nonatomic) IBOutlet UIView *branchOverlay, *branchCtrlContainer;
@property (strong, nonatomic) IBOutlet UIButton *revealBranchOverlayButton;

@property (strong, nonatomic) IBOutlet UIButton *grabButton;

// Private. Category-visible methods.
- (void)reloadFilters;
- (void)reloadCommits;
- (void)addForgetButton;
@end
