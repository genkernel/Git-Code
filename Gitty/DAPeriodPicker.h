//
//  DAPeriodPicker.h
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"
#import "DAPeriod.h"

@interface DAPeriodPicker : DABaseCtrl <UIPickerViewDataSource, UIPickerViewDelegate>
- (void)selectPeriodItem:(DAPeriod *)period animated:(BOOL)animated;

@property (strong, nonatomic) void (^completionBlock)(DAPeriod *);
@property (strong, nonatomic) void (^cancelBlock)();

@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@end
