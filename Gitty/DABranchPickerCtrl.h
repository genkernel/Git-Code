//
//  DAPickerCtrl.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DABranchPickerCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
- (void)resetWithBranches:(NSArray *)branches;

@property (strong, nonatomic) void (^completionBlock)(GTBranch *);

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *mainTable;
@end
