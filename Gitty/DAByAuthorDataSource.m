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

- (BOOL)treeView:(UITableView *)tableView toggleCellAtIndexPath:(NSIndexPath *)indexPath treeIndexPath:(NSIndexPath *)ip {
	BOOL expanded = [super treeView:tableView toggleCellAtIndexPath:indexPath treeIndexPath:ip];
	
	DAAuthorHeaderCell *header = (DAAuthorHeaderCell *)[tableView cellForRowAtIndexPath:indexPath];
	header.collapsed = !expanded;
	
	return expanded;
}

#pragma mark Properties

- (NSArray *)sections {
	return self.stats.authors;
}

- (NSDictionary *)sectionItems {
	return self.stats.authorCommits;
}

#pragma mark Internal

- (DACommitBranchCell *)reusableBranchCellRegisteredByTable:(UITableView *)tableView {
	if (!self.reusableBranchCell) {
		_reusableBranchCell = [tableView dequeueReusableCellWithIdentifier:DACommitBranchCell.className];
	}
	
	return self.reusableBranchCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView headerViewAtIndexPath:(NSIndexPath *)ip {
	DAAuthorHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:DAAuthorHeaderCell.className];
	
	NSString *key = self.sections[ip.row];
	GTSignature *author = self.stats.authorRefs[key];
	
	[cell loadAuthor:author];
	
	cell.collapsed = [self.closedItems containsObject:ip];
	
	return cell;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *ip = [tableView treeIndexPathFromTablePath:indexPath];
	
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
	
	NSUInteger section = [indexPath indexAtPosition:1];
	NSUInteger row = [indexPath indexAtPosition:2];
	
	NSString *key = self.sections[section];
	GTSignature *author = self.stats.authorRefs[key];
	
	NSArray *commits = self.sectionItems[key];
	GTCommit *commit = commits[row];
	
	NSString *identifier = DACommitBranchCell.className;
	UITableViewCell<DADynamicCommitCell> *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[cell setShowsDayName:YES];
	[cell setShowsTopCellSeparator:row > 0];
	
	[cell loadCommit:commit author:author];
	
	NSString *head = self.stats.commitToBranchMap[commit.SHA];
	GTBranch *br = self.stats.headRefs[head];
	
	[((DACommitBranchCell *)cell) loadBranch:br];
	
	return cell;
}

@end
