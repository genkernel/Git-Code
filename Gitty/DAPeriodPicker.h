//
//  DAPeriodPicker.h
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DAPeriodPicker : DABaseCtrl <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) void (^completionBlock)(NSUInteger idx, NSNumber *period);
@property (strong, nonatomic) void (^cancelBlock)();

@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@end
