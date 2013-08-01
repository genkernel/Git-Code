//
//  DAPickerCtrl.m
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABranchPickerCtrl.h"

@interface DABranchPickerCtrl ()
@property (strong, nonatomic) NSArray *allBranches;
@property (strong, nonatomic, readonly) NSArray *visibleBranches;
@end

@implementation DABranchPickerCtrl

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.mainTable.scrollsToTop = NO;
	
	[self.searchBar enableAllControlButtons];
	
	[self.mainTable registerClass:UITableViewCell.class forCellReuseIdentifier:UITableViewCell.className];
}

- (void)resetWithBranches:(NSArray *)branches {
	self.searchBar.text = nil;
	
	[self reloadWithBranches:branches];
}

- (void)reloadWithBranches:(NSArray *)branches {
	_allBranches = branches.copy;
	
	[self filterBranchListWithSearchText:self.searchBar.text];
	
	[self.searchBar enableAllControlButtons];
}

- (void)filterBranchListWithSearchText:(NSString *)text {
	if (text.length == 0) {
		_visibleBranches = self.allBranches;
		
	} else if (text.length < 3) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortName beginswith[cd] %@", text];
		
		_visibleBranches = [self.allBranches filteredArrayUsingPredicate:predicate];
		
	} else {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortName contains[cd] %@", text];
		
		_visibleBranches = [self.allBranches filteredArrayUsingPredicate:predicate];
	}
	
	[self.mainTable reloadData];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.visibleBranches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GTBranch *branch = self.visibleBranches[indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCell.className];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	cell.textLabel.text = branch.shortName;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self.searchBar resignFirstResponder];
	[self.searchBar enableAllControlButtons];
	
	self.completionBlock(self.visibleBranches[indexPath.row]);
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterBranchListWithSearchText:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[self.searchBar enableAllControlButtons];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	
	self.completionBlock(nil);
}

@end
