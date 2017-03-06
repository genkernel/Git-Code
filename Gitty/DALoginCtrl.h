//
//  DAViewController.h
//  Gitty
//
//  Created by kernel on 28/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"
#import "PagerView.h"

@interface DALoginCtrl : DABaseCtrl <PagerViewDataSource, PagerViewDelegate, PageControlDelegate>
@property (strong, nonatomic) IBOutlet UIButton *sshButton;
@property (strong, nonatomic) IBOutlet UIPageControl *serverDotsControl;
@property (strong, nonatomic) IBOutlet PagerView *pager;

- (void)exploreRepoWithPath:(NSString *)path;
- (DAGitServer *)createNewServerWithDictionary:(NSDictionary *)info;

- (void)scrollToServer:(DAGitServer *)server animated:(BOOL)animated;
@end
