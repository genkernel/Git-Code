//
//  DADiffCtrl+UI.h
//  Gitty
//
//  Created by kernel on 24/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADiffCtrl.h"

@interface DADiffCtrl (UI)
- (UIView *)cachedViewWithIdentifier:(NSString *)identifier;
- (void)cacheView:(UIView *)view withIdentifier:(NSString *)identifier;
@end
