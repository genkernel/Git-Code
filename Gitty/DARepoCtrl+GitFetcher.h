//
//  DARepoCtrl+GitFetcher.h
//  Gitty
//
//  Created by kernel on 4/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl.h"

@interface DARepoCtrl (GitFetcher)
- (void)loadCommitsInBranch:(GTBranch *)branch betweenNowAndDate:(NSDate *)date;
- (void)pull;
@end
