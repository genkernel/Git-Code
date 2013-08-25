//
//  DAPickerCtrl.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl.h"
#import "DABranchPickerCtrl+Private.h"

#import "DABranchPickerCtrl+Style.h"
#import "DABranchPickerCtrl+Animation.h"
#import "DABranchPickerCtrl+Responder.h"

@interface DABranchPickerCtrl ()
@end

@implementation DABranchPickerCtrl
@dynamic visibleTable;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tagsTable.scrollsToTop = NO;
	self.branchesTable.scrollsToTop = NO;
	
	[self.searchBar enableAllControlButtons];
	[self.searchBar setKeyboardAppearance:UIKeyboardAppearanceAlert];
	
	self.tabBar.selectedItem = self.tabBar.items[DABranchList];
	
	_selectedIndexPaths = [NSMutableArray arrayWithCapacity:DAListModesMax];
	for (int i = 0; i < DAListModesMax; i++) {
		self.selectedIndexPaths[i] = NSIndexPath.new;
	}
	
	_filteredItems = [NSMutableArray arrayWithCapacity:DAListModesMax];
	for (int i = 0; i < DAListModesMax; i++) {
		self.filteredItems[i] = NSArray.new;
	}
}

- (void)loadItemsWithoutFilter {
	self.filteredItems[DATagList] = self.tags;
	self.filteredItems[DABranchList] = self.branches;
	
	BOOL hasTags = self.tags.count > 0;
	
	self.tagsTable.hidden = !hasTags;
	self.noTagsLabel.hidden = hasTags;
}

- (void)resetUI {
	self.searchBar.text = nil;
	
	[self reloadUI];
}

- (void)reloadUI {
	[self filterVisibleListWithSearchText:self.searchBar.text];
	
	[self.searchBar enableAllControlButtons];
}

- (void)filterVisibleListWithSearchText:(NSString *)text {
	if (text.length == 0) {
		[self loadItemsWithoutFilter];
		
	} else if (text.length == 1) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[cd] %@", text];
		self.filteredItems[DATagList] = [self.tags filteredArrayUsingPredicate:predicate];
		
		predicate = [NSPredicate predicateWithFormat:@"shortName beginswith[cd] %@", text];
		self.filteredItems[DABranchList] = [self.branches filteredArrayUsingPredicate:predicate];
		
	} else {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", text];
		self.filteredItems[DATagList] = [self.tags filteredArrayUsingPredicate:predicate];
		
		predicate = [NSPredicate predicateWithFormat:@"shortName contains[cd] %@", text];
		self.filteredItems[DABranchList] = [self.branches filteredArrayUsingPredicate:predicate];
	}
	
	[self.tagsTable reloadData];
	[self.branchesTable reloadData];
}

#pragma mark Properties

- (UITableView *)visibleTable {
	return DABranchList == listMode ? self.branchesTable : self.tagsTable;
}

- (void)setCurrentBranch:(GTBranch *)branch {
	if (self.currentBranch) {
		NSUInteger row = [self.branches indexOfObject:self.currentBranch];
		NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
		[self deselectCellAtIndexPath:ip table:self.branchesTable];
	}
	
	_currentBranch = branch;
	
	NSUInteger idx = [self.branches indexOfObject:branch];
	if (NSNotFound == idx) {
		return;
	}
	
	[self updateSelectedCellWithRowNumber:idx inTable:self.branchesTable];
}

- (void)setCurrentTag:(GTTag *)tag {
	if (self.currentTag) {
		NSUInteger row = [self.tags indexOfObject:self.currentTag];
		NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
		[self deselectCellAtIndexPath:ip table:self.tagsTable];
	}
	
	_currentTag = tag;
	
	NSUInteger idx = [self.tags indexOfObject:tag];
	if (NSNotFound == idx) {
		return;
	}
	
	[self updateSelectedCellWithRowNumber:idx inTable:self.tagsTable];
}

@end
