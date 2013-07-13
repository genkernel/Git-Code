//
//  DAPickerCtrl.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl.h"

@implementation DABranchPickerCtrl

#pragma mark UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.branches.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	GTBranch *branch = self.branches[row];
	return branch.shortName;
}

#pragma mark Actions

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
	self.completionBlock(nil);
}

- (IBAction)checkoutPressed:(UIBarButtonItem *)sender {
	NSInteger row = [self.picker selectedRowInComponent:0];
	self.completionBlock(self.branches[row]);
}

@end
