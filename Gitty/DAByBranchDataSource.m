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

#pragma mark Properties

- (NSArray *)sections {
	return self.stats.heads;
}

- (NSDictionary *)sectionItems {
	return self.stats.headCommits;
}

#pragma mark Helper methods

// Commit is Subsequent when its previous commit is prepared by the same Author (in the very same Day).
- (BOOL)isSubsequentCommitAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath indexAtPosition:1];
	NSUInteger row = [indexPath indexAtPosition:2];
	
	BOOL previousCommitHasSameAuthor = NO;
	
	BOOL hasPreviousCommitInSection = row > 0;
	if (hasPreviousCommitInSection) {
		NSString *key = self.sections[section];
		NSArray *commits = self.sectionItems[key];
		
		GTCommit *commit = commits[row];
		GTCommit *prevCommit = commits[row - 1];
		
		GTSignature *author = [self.stats authorForCommit:commit];
		GTSignature *prevAuthor = [self.stats authorForCommit:prevCommit];
		
		previousCommitHasSameAuthor = [author isEqual:prevAuthor];
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
	NSString *key = self.sections[section];
	GTBranch *branch = self.stats.headRefs[key];
	
	DATitleHeaderCell *header = [tableView dequeueReusableCellWithIdentifier:DATitleHeaderCell.className];
	
	header.nameLabel.text = branch.shortName;
	
	return header;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *ip = [tableView treeIndexPathFromTablePath:indexPath];
	
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.length == 2) {
		return [self tableView:tableView headerViewAtIndex:indexPath.row];
	}
	
	NSUInteger row = [indexPath indexAtPosition:2];
	
	GTCommit *commit = [self commitForIndexPath:indexPath];
	GTSignature *author = [self.stats authorForCommit:commit];
	
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:indexPath];
	Class cls = previousCommitHasSameAuthor ? DACommitMessageCell.class : DACommitCell.class;
	
	NSString *identifier = NSStringFromClass(cls);
	UITableViewCell<DADynamicCommitCell> *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[cell setShowsDayName:YES];
	[cell setShowsTopCellSeparator:row > 0];
	
	[cell loadCommit:commit author:author];
	
	return cell;
}

@end
