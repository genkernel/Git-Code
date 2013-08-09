//
//  DAPickerCtrl.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

typedef enum {
	DABranchList,
	DATagList,
	DAListModesMax
} DAListModes;

@interface DABranchPickerCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate> {
	DAListModes listMode;
}
@property (strong, nonatomic) NSArray *tags, *branches;

- (void)loadItemsWithoutFilter;

// Invalidates dataSources, Reloads UI and clears search text.
- (void)resetUI;
// reloadUI does not clear searching text as opposite to resetUI.
- (void)reloadUI;

@property (strong, nonatomic) void (^branchSelectedAction)(GTBranch *);
@property (strong, nonatomic) void (^tagSelectedAction)(GTTag *);
@property (strong, nonatomic) void (^cancelAction)();

@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIView *container;

// visibleTable is @dynamic points to branchesTable or tagsTable.
@property (strong, nonatomic, readonly) UITableView *visibleTable;
@property (strong, nonatomic) IBOutlet UITableView *branchesTable, *tagsTable;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *branchesTableLeft;

@property (strong, nonatomic) IBOutlet UILabel *noTagsLabel;
@end
