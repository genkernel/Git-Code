//
//  DAPickerCtrl.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DABranchPickerCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
// Reloads dataSource and clears search text.
- (void)resetWithBranches:(NSArray *)branches;
// reloadWithBranches: does not clear searching text as opposite to resetWithBranches:.
- (void)reloadWithBranches:(NSArray *)branches;

@property (strong, nonatomic) void (^completionBlock)(GTBranch *);

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *mainTable;
@end
