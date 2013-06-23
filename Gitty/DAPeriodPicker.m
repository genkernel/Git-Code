//
//  DAPeriodPicker.m
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAPeriodPicker.h"
#import "DAPeriodPicker+Helper.h"

@interface DAPeriodPicker ()
@property (strong, nonatomic, readonly) NSArray *periods;
@end

@implementation DAPeriodPicker

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_periods = @[self.noLimit,
				 self.today/*,
				 NSLocalizedString(@"Yesterday", nil),
				 NSLocalizedString(@"Last 3 days", nil),
				 NSLocalizedString(@"Last week", nil),
				 NSLocalizedString(@"Last month", nil)*/];
}

- (void)selectPeriodItem:(DAPeriod *)period animated:(BOOL)animated {
	NSUInteger idx = [self.periods indexOfObject:period];
	if (NSNotFound != idx) {
		[self.picker selectRow:idx inComponent:0 animated:NO];
	}
}

#pragma mark UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.periods.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	DAPeriod *period = self.periods[row];
	return period.title;
}

#pragma mark Actions

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
	self.cancelBlock();
}

- (IBAction)checkoutPressed:(UIBarButtonItem *)sender {
	NSInteger row = [self.picker selectedRowInComponent:0];
	self.completionBlock(self.periods[row]);
}

@end
