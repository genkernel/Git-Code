//
//  DAServerCtrl+AutoLayout.h
//  Gitty
//
//  Created by kernel on 2/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAServerCtrl.h"

@interface DAServerCtrl (AutoLayout)
- (void)layoutProtocolsContainer;
- (void)insertAndLayoutNextProtocolButton:(UIButton *)button;
@end
