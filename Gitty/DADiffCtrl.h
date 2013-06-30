//
//  DADiffCtrl.h
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"
#import "DADiffCtrlDataSource.h"

@interface DADiffCtrl : DABaseCtrl <UITableViewDataSource, UITableViewDelegate> {
	NSMutableDictionary *_cachedViews;
}
@property (strong, nonatomic) DADiffCtrlDataSource *diff;

@property (strong, nonatomic) IBOutlet UITableView *table;
@end
