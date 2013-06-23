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
@property (strong, nonatomic, readonly) NSArray *periodValues;
@end

@implementation DAPeriodPicker

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_periods = @[NSLocalizedString(@"No limit", nil),
				 NSLocalizedString(@"Today", nil)/*,
				 NSLocalizedString(@"Yesterday", nil),
				 NSLocalizedString(@"Last 3 days", nil),
				 NSLocalizedString(@"Last week", nil),
				 NSLocalizedString(@"Last month", nil)*/];
	
	__weak DAPeriodPicker *ref = self;
	_periodValues = @[^(){
		return nil;	// Infinite.
	}, ^(){
		return @(ref.today);
	}];
}

#pragma mark UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.periods.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return self.periods[row];
}

#pragma mark Actions

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
	self.cancelBlock();
}

- (IBAction)checkoutPressed:(UIBarButtonItem *)sender {
	NSInteger row = [self.picker selectedRowInComponent:0];
	NSNumber *(^block)() = self.periodValues[row];
	self.completionBlock(row, block());
}

@end
