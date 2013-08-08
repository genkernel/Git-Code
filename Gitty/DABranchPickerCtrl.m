//
//  DAPickerCtrl.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl.h"
#import "DABranchPickerCtrl+Animation.h"

@interface DABranchPickerCtrl ()
// format: [idx]	=>	<NSArray of concrete items>
@property (strong, nonatomic) NSMutableArray *filteredItems;
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
	
	_filteredItems = [NSMutableArray arrayWithCapacity:DAListModesMax];
	for (int i = 0; i < DAListModesMax; i++) {
		self.filteredItems[i] = NSArray.new;
	}
}

- (void)loadItemsWithoutFilter {
	self.filteredItems[DATagList] = self.tags;
	self.filteredItems[DABranchList] = self.branches;
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
		
	} else if (text.length < 3) {
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

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *items = self.filteredItems[tableView.tag];
	return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DAListModes tableType = tableView.tag;
	NSArray *items = self.filteredItems[tableType];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCell.className];
	if (!cell) {
		
		if (DABranchList == tableType) {
			cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GTBranch.className];
		} else {
			cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GTTag.className];
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	if (DABranchList == tableType) {
		GTBranch *branch = items[indexPath.row];
		cell.textLabel.text = branch.shortName;
	} else {
		GTTag *tag = items[indexPath.row];
		cell.textLabel.text = tag.name;
		cell.detailTextLabel.text = tag.message;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self.searchBar resignFirstResponder];
	[self.searchBar enableAllControlButtons];
	
	DAListModes tableType = tableView.tag;
	NSArray *items = self.filteredItems[tableType];
	
	if (DABranchList == tableType) {
		self.branchSelectedAction(items[indexPath.row]);
	} else {
		self.tagSelectedAction(items[indexPath.row]);
	}
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterVisibleListWithSearchText:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[self.searchBar enableAllControlButtons];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	
	self.cancelAction();
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	[self setListMode:item.tag animated:YES];
}

#pragma mark Properties

- (UITableView *)visibleTable {
	return DABranchList == listMode ? self.branchesTable : self.tagsTable;
}

@end
