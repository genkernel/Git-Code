//
//  DARepoCtrl+Table.h
//  Gitty
//
//  Created by kernel on 18/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DARepoCtrl.h"

// Cells.
#import "DACommitCell.h"
#import "DATitleHeader.h"
#import "DATitleHeaderCell.h"
#import "DACommitMessageCell.h"

@interface DARepoCtrl (Table) <UITableViewDataSource, UITableViewDelegate>
- (void)setupCells;
@end
