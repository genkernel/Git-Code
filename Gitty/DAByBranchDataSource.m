//
//  DAByBranchDataSource.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAByBranchDataSource.h"
#import "DATitleHeader.h"

#import "DACommitCell.h"
#import "DACommitBranchCell.h"
#import "DACommitMessageCell.h"

@implementation DAByBranchDataSource

- (id)init {
	self = [super init];
	if (self) {
		DATitleHeader *header = DATitleHeader.new;
		headerHeight = header.height;
		[self cacheView:header withIdentifier:DATitleHeader.className];
	}
	return self;
}

#pragma mark Internal

- (DACommitCell *)reusableCellRegisteredByTable:(UITableView *)tableView {
	static DACommitCell *cell = nil;
	if (!cell) {
		cell = [tableView dequeueReusableCellWithIdentifier:DACommitCell.className];
	}
	return cell;
}

- (DACommitMessageCell *)reusableMessageCellRegisteredByTable:(UITableView *)tableView {
	static DACommitMessageCell *cell = nil;
	if (!cell) {
		cell = [tableView dequeueReusableCellWithIdentifier:DACommitMessageCell.className];
	}
	return cell;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = self.commits.allKeys[section];
	
	NSString *identifier = DATitleHeader.className;
	DATitleHeader *header = (DATitleHeader *)[self cachedViewWithIdentifier:identifier];
	if (!header) {
		header = DATitleHeader.new;
	}
	
	header.nameLabel.text = title;
	
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<DADynamicCommitCell> cell = nil;
	GTCommit *commit = [self commitForIndexPath:indexPath];
	
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:indexPath];
	if (previousCommitHasSameAuthor) {
		cell = [self reusableMessageCellRegisteredByTable:tableView];
	} else {
		cell = [self reusableCellRegisteredByTable:tableView];
	}
	
	return [cell heightForCommit:commit];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GTCommit *commit = [self commitForIndexPath:indexPath];
	
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:indexPath];
	Class cls = previousCommitHasSameAuthor ? DACommitMessageCell.class : DACommitCell.class;
	
	NSString *identifier = NSStringFromClass(cls);
	UITableViewCell<DADynamicCommitCell> *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[cell setShowsDayName:self.shouldIncludeDayNameInTimestamp];
	[cell setShowsTopCellSeparator:indexPath.row > 0];
	
	[cell loadCommit:commit];
	
	return cell;
}

@end
