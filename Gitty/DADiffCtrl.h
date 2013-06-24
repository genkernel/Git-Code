//
//  DADiffCtrl.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DADiffCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate> {
	NSMutableDictionary *_cachedViews;
}
@property (strong, nonatomic) GTCommit *changeCommit;

@property (strong, nonatomic) IBOutlet UITableView *table;
@end
