//
//  DACommitBranchCell.h
//  Gitty
//
//  Created by kernel on 12/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DADynamicCommitCell.h"

@interface DACommitBranchCell : UITableViewCell <DADynamicCommitCell>
- (void)loadBranch:(GTBranch *)branch;

@property (strong, nonatomic) IBOutlet UIView *separatorLine;

@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *commitLabel;
@end
