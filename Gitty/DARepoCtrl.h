//
//  DARepoCtrl.h
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DARepoCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate> {
	BOOL isBranchOverlayVisible, isPeriodOverlayVisible;
	BOOL isFiltersContainerVisible;
}
@property (strong, nonatomic) GTRepository *currentRepo;
@property (nonatomic) BOOL shouldPull;

@property (strong, nonatomic) IBOutlet UIView *commitsContainer;
@property (strong, nonatomic) IBOutlet UITableView *commitsTable;

@property (strong, nonatomic) IBOutlet UIButton *currentBranchButton;
@property (strong, nonatomic) IBOutlet UIView *branchOverlay, *periodOverlay;

@property (strong, nonatomic) IBOutlet UIView *grayOverlay;
@property (strong, nonatomic) IBOutlet UIView *headerContainer;
@property (strong, nonatomic) IBOutlet UITextField *pullingField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *pullingIndicator;

@property (strong, nonatomic) IBOutlet UIView *filtersContainer, *innerFiltersContainer;
@property (strong, nonatomic) IBOutlet UIButton *toggleFiltersButton;

// Private. Category-visible methods.
- (void)reloadFilters;
- (void)reloadCommits;
@end
