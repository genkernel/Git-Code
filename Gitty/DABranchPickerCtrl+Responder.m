//
//  DABranchPickerCtrl+Responder.m
//  Gitty
//
//  Created by kernel on 10/08/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl+Responder.h"
#import "DABranchPickerCtrl+Private.h"

#import "DABranchPickerCtrl+Style.h"
#import "DABranchPickerCtrl+Animation.h"

@implementation DABranchPickerCtrl (Responder)

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *items = self.filteredItems[tableView.tag];
	return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DAListModes tableType = (int)tableView.tag;
	NSArray *items = self.filteredItems[tableType];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCell.className];
	if (!cell) {
		
		if (DABranchList == tableType) {
			cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GTBranch.className];
		} else {
			cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GTTag.className];
		}
		
		cell.backgroundColor = UIColor.clearColor;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	BOOL isPresentingActiveCell = NO;
	
	if (DABranchList == tableType) {
		GTBranch *branch = items[indexPath.row];
		cell.textLabel.text = branch.shortName;
		
		isPresentingActiveCell = [branch isEqual:self.currentBranch];
	} else {
		GTTag *tag = items[indexPath.row];
		cell.textLabel.text = tag.name;
		cell.detailTextLabel.text = tag.message;
		
		isPresentingActiveCell = [tag isEqual:self.currentTag];
	}
	
	cell.textLabel.textColor = isPresentingActiveCell ? self.activeTitleColor : self.titleColor;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//	[self toggleSelectedCellWithNewIndexPath:indexPath inTable:tableView];
	
	[self.searchBar resignFirstResponder];
	[self.searchBar enableAllControlButtons];
	
	DAListModes tableType = (int)tableView.tag;
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

@end
