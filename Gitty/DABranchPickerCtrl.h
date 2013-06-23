//
//  DAPickerCtrl.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DABranchPickerCtrl : DABaseCtrl <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) NSArray *branches;
@property (strong, nonatomic) void (^completionBlock)(GTBranch *);

@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@end
