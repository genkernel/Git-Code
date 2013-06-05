//
//  DADiffCtrl.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DADiffCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) GTCommit *previousCommit, *changeCommit;

@property (strong, nonatomic) IBOutlet UITableView *table;
@end
