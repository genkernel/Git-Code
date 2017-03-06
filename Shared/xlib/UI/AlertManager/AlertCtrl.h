//
//  AlertCtrl.h
//  Gitty
//
//  Created by kernel on 23/08/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "ViewCtrl.h"

@class CustomAlert;

@interface AlertCtrl : ViewCtrl
@property (weak, nonatomic) CustomAlert *alertPresenter;
@end
