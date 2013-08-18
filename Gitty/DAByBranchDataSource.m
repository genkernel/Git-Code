//
//  DAByBranchDataSource.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAByBranchDataSource.h"
#import "DATitleHeaderCell.h"

@interface DAByBranchDataSource ()
@property (strong, nonatomic, readonly) DACommitCell *reusableCell;
@property (strong, nonatomic, readonly) DACommitMessageCell *reusableMessageCell;
@end

@implementation DAByBranchDataSource

- (void)setupForTableView:(UITableView *)tableView {
	[super setupForTableView:tableView];
	
	UINib *nib = [UINib nibWithNibName:DATitleHeaderCell.className bundle:nil];
	[tableView registerNib:nib forCellReuseIdentifier:DATitleHeaderCell.className];
	
	UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:DATitleHeaderCell.className];
	headerHeight = header.height;
}

#pragma mark Helper methods

- (GTCommit *)commitForIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath indexAtPosition:1];
	NSUInteger row = [indexPath indexAtPosition:2];
	
	GTBranch *br = self.stats.heads[section];
	NSArray *commits = self.stats.headCommits[br.SHA];
	
	return commits[row];
}

// Commit is Subsequent when its previous commit is prepared by the same Author (in the very same Day).
- (BOOL)isSubsequentCommitAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath indexAtPosition:1];
	NSUInteger row = [indexPath indexAtPosition:2];
	
	BOOL previousCommitHasSameAuthor = NO;
	
	BOOL hasPreviousCommitInSection = row > 0;
	if (hasPreviousCommitInSection) {
		GTBranch *br = self.stats.heads[section];
		NSArray *commits = self.stats.headCommits[br.SHA];
		
		GTCommit *commit = commits[row];
		GTCommit *prevCommit = commits[row - 1];
		
		previousCommitHasSameAuthor = [commit.author isEqual:prevCommit.author];
	}
	
	return previousCommitHasSameAuthor;
}

#pragma mark Internal

- (DACommitCell *)reusableCellRegisteredByTable:(UITableView *)tableView {
	if (!self.reusableCell) {
		_reusableCell = [tableView dequeueReusableCellWithIdentifier:DACommitCell.className];
	}
	return self.reusableCell;
}

- (DACommitMessageCell *)reusableMessageCellRegisteredByTable:(UITableView *)tableView {
	if (!self.reusableMessageCell) {
		_reusableMessageCell = [tableView dequeueReusableCellWithIdentifier:DACommitMessageCell.className];
	}
	return self.reusableMessageCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView headerViewAtIndex:(NSInteger)section {
	GTBranch *branch = self.stats.heads[section];
	
	DATitleHeaderCell *header = [tableView dequeueReusableCellWithIdentifier:DATitleHeaderCell.className];
	
	header.nameLabel.text = branch.shortName;
	
	return header;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	TreeTable *proxy = tableView.dataSource;
	NSIndexPath *ip = [proxy treeIndexPathFromTablePath:indexPath];
	
	if (ip.length == 2) {
		return headerHeight;
	}
	
	id<DADynamicCommitCell> cell = nil;
	GTCommit *commit = [self commitForIndexPath:ip];
	
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:ip];
	if (previousCommitHasSameAuthor) {
		cell = [self reusableMessageCellRegisteredByTable:tableView];
	} else {
		cell = [self reusableCellRegisteredByTable:tableView];
	}
	
	return [cell heightForCommit:commit];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.stats.heads.count;
}

- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.length != 2) {
		return 0;
	}
	
	GTBranch *br = self.stats.heads[indexPath.row];
	NSArray *commits = self.stats.headCommits[br.SHA];
	
	return commits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.length == 2) {
		return [self tableView:tableView headerViewAtIndex:indexPath.row];
	}
	
	NSUInteger row = [indexPath indexAtPosition:2];
	
	GTCommit *commit = [self commitForIndexPath:indexPath];
	
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:indexPath];
	Class cls = previousCommitHasSameAuthor ? DACommitMessageCell.class : DACommitCell.class;
	
	NSString *identifier = NSStringFromClass(cls);
	UITableViewCell<DADynamicCommitCell> *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[cell setShowsDayName:self.shouldIncludeDayNameInTimestamp];
	[cell setShowsTopCellSeparator:row > 0];
	
	[cell loadCommit:commit];
	
	return cell;
}

@end
