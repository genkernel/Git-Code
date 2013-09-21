//
//  DABaseCtrl+Internal.h
//  Gitty
//
//  Created by kernel on 21/09/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DABaseCtrl ()
@property (strong, nonatomic) void (^presentedAction)();
@property (strong, nonatomic) void (^dismissedAction)();
@end
