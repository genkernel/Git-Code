//
//  DARepoCtrl+Animation.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DARepoCtrl.h"

@interface DARepoCtrl (Animation)
- (void)setBranchOverlayVisible:(BOOL)visible animated:(BOOL)animated;
- (void)setDiffLoadingOverlayVisible:(BOOL)visible animated:(BOOL)animated;

- (void)setPullingViewVisible:(BOOL)visible animated:(BOOL)animated;
//- (void)setStatsHeadlineViewVisible:(BOOL)visible animated:(BOOL)animated;
- (void)setStatsContainerMode:(DAStatsContainerModes)mode animated:(BOOL)animated;

- (void)loadStatsHeadline;
@end
