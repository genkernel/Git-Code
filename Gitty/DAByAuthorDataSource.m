//
//  DAStatscommits.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAByAuthorDataSource.h"
#import "DAAuthorHeaderCell.h"

@interface DAByAuthorDataSource ()
@property (strong, nonatomic, readonly) DACommitBranchCell *reusableBranchCell;
@end

@implementation DAByAuthorDataSource

- (void)setupForTableView:(UITableView *)tableView {
	[super setupForTableView:tableView];
	
	UINib *nib = [UINib nibWithNibName:DAAuthorHeaderCell.className bundle:nil];
	[tableView registerNib:nib forCellReuseIdentifier:DAAuthorHeaderCell.className];
	
	UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:DAAuthorHeaderCell.className];
	headerHeight = header.height;
}

- (BOOL)treeView:(TreeTable *)proxy toggleCellAtIndexPath:(NSIndexPath *)indexPath treeIndexPath:(NSIndexPath *)ip {
	BOOL expanded = [super treeView:proxy toggleCellAtIndexPath:indexPath treeIndexPath:ip];
	
	DAAuthorHeaderCell *header = (DAAuthorHeaderCell *)[proxy.tableView cellForRowAtIndexPath:indexPath];
	header.collapsed = !expanded;
	
	return expanded;
}

#pragma mark Internal

- (DACommitBranchCell *)reusableBranchCellRegisteredByTable:(UITableView *)tableView {
	if (!self.reusableBranchCell) {
		_reusableBranchCell = [tableView dequeueReusableCellWithIdentifier:DACommitBranchCell.className];
	}
	
	return self.reusableBranchCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView headerViewAtIndexPath:(NSIndexPath *)ip {
	NSString *title = self.commits.allKeys[ip.row];
	
	DAAuthorHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:DAAuthorHeaderCell.className];
	
	GTSignature *author = self.authors[title];
	[cell loadAuthor:author];
	
	cell.collapsed = [self.closedItems containsObject:ip];
	
	return cell;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	TreeTable *proxy = tableView.dataSource;
	NSIndexPath *ip = [proxy treeIndexPathFromTablePath:indexPath];
	
	if (ip.length == 2) {
		return headerHeight;
	}
	
	GTCommit *commit = [self commitForIndexPath:ip];
	
	id<DADynamicCommitCell> cell = [self reusableBranchCellRegisteredByTable:tableView];
	
	return [cell heightForCommit:commit];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.length == 2) {
		return [self tableView:tableView headerViewAtIndexPath:indexPath];
	}
	
	NSUInteger row = [indexPath indexAtPosition:2];
	
	GTCommit *commit = [self commitForIndexPath:indexPath];
	
	NSString *identifier = DACommitBranchCell.className;
	UITableViewCell<DADynamicCommitCell> *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[cell setShowsDayName:self.shouldIncludeDayNameInTimestamp];
	[cell setShowsTopCellSeparator:row > 0];
	
	[cell loadCommit:commit];
	
	NSString *addr = [NSString stringWithFormat:@"0x%X", (int)commit];
	GTBranch *branch = self.branches[addr];
	[((DACommitBranchCell *)cell) loadBranch:branch];
	
	return cell;
}

@end
