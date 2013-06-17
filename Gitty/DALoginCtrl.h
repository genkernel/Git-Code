//
//  DAViewController.h
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DALoginCtrl : DABaseCtrl <PagerViewDataSource, PagerViewDelegate>
@property (strong, nonatomic) IBOutlet PagerView *pager;
@end
