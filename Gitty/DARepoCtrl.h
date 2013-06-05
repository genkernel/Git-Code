//
//  DARepoCtrl.h
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DARepoCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate> {
	BOOL isBranchOverlayVisible;
}
@property (strong, nonatomic) GTRepository *currentRepo;

@property (strong, nonatomic) IBOutlet UITableView *commitsTable;
@property (strong, nonatomic) IBOutlet UIButton *currentBranchButton;
@property (strong, nonatomic) IBOutlet UIView *branchOverlay;
@end
