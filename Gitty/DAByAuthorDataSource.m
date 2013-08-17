//
//  DAStatscommits.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAByAuthorDataSource.h"
#import "DAAuthorHeader.h"

#import "DACommitBranchCell.h"

@implementation DAByAuthorDataSource

- (id)init {
	self = [super init];
	if (self) {
		DAAuthorHeader *header = DAAuthorHeader.new;
		headerHeight = header.height;
		[self cacheView:header withIdentifier:DAAuthorHeader.className];
	}
	return self;
}

#pragma mark Internal

- (DACommitBranchCell *)reusableBranchCellRegisteredByTable:(UITableView *)tableView {
	static DACommitBranchCell *cell = nil;
	if (!cell) {
		cell = [tableView dequeueReusableCellWithIdentifier:DACommitBranchCell.className];
	}
	return cell;
}

- (UITableViewCell *)headerViewAtIndex:(NSInteger)section {
	NSString *title = self.commits.allKeys[section];
	
	NSString *identifier = DAAuthorHeader.className;
	DAAuthorHeader *view = (DAAuthorHeader *)[self cachedViewWithIdentifier:identifier];
	if (!view) {
		view = DAAuthorHeader.new;
	}
	
	GTSignature *author = self.authors[title];
	[view loadAuthor:author];
	
	return view;
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
		return [self headerViewAtIndex:indexPath.row];
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
