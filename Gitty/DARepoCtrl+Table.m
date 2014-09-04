//
//  DARepoCtrl+Table.m
//  Gitty
//
//  Created by kernel on 18/08/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "DARepoCtrl+Table.h"
#import "DARepoCtrl+Internal.h"

@interface UITableView (RepoCtrl)
- (id)dequeueCellOfClass:(Class)cls;
- (NSString *)cellIdentifierOfClass:(Class)cls;
@end


@implementation DARepoCtrl (Table)

- (void)setupCells {
	headerHeight = DATitleHeader.new.height;
	
	{
		NSString *identifier = [self.commitsTable cellIdentifierOfClass:DACommitCell.class];
		
		UINib *nib = [UINib nibWithNibName:DACommitCell.className bundle:nil];
		[self.commitsTable registerNib:nib forCellReuseIdentifier:identifier];
		
		self.reuseCell = [self.commitsTable dequeueCellOfClass:DACommitCell.class];
	}
	{
		NSString *identifier = [self.commitsTable cellIdentifierOfClass:DACommitMessageCell.class];
		
		UINib *nib = [UINib nibWithNibName:DACommitMessageCell.className bundle:nil];
		[self.commitsTable registerNib:nib forCellReuseIdentifier:identifier];
		
		self.reuseSimpleCell = [self.commitsTable dequeueCellOfClass:DACommitMessageCell.class];
	}
}

#pragma mark Internal Helpers

- (GTCommit *)commitForIndexPath:(NSIndexPath *)indexPath {
	NSString *title = self.currentStats.dateSections[indexPath.section];
	NSArray *commits = self.currentStats.commitsOnDateSection[title];
	
	return commits[indexPath.row];
}

// Commit is Subsequent when its previous commit is prepared by the same Author in the very same Day.
- (BOOL)isSubsequentCommitAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger idx = indexPath.row;
	BOOL previousCommitHasSameAuthor = NO;
	
	BOOL hasPreviousCommitInSection = idx > 0;
	if (hasPreviousCommitInSection) {
		NSString *title = self.currentStats.dateSections[indexPath.section];
		NSArray *commits = self.currentStats.commitsOnDateSection[title];
		
		GTCommit *commit = commits[idx];
		GTCommit *prevCommit = commits[idx - 1];
		
		GTSignature *author = [self.currentStats authorForCommit:commit];
		GTSignature *prevAuthor = [self.currentStats authorForCommit:prevCommit];
		
		previousCommitHasSameAuthor = [author isEqual:prevAuthor];
	}
	
	return previousCommitHasSameAuthor;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.currentStats.dateSections.count;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
	[self cacheView:view withIdentifier:view.className];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	DATitleHeader *header = (DATitleHeader *)[self cachedViewWithIdentifier:DATitleHeader.className];
	if (!header) {
		header = DATitleHeader.new;
	}
	
	header.nameLabel.text = self.currentStats.dateSections[section];
	
	return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *title = self.currentStats.dateSections[section];
	NSArray *commits = self.currentStats.commitsOnDateSection[title];
	
	return commits.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:indexPath];
	
	DACommitMessageCell *cell = previousCommitHasSameAuthor ? self.reuseSimpleCell : self.reuseCell;
	
	GTCommit *commit = [self commitForIndexPath:indexPath];
	return [cell heightForCommit:commit];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GTCommit *commit = [self commitForIndexPath:indexPath];
	GTSignature *author = [self.currentStats authorForCommit:commit];
	
	BOOL previousCommitHasSameAuthor = [self isSubsequentCommitAtIndexPath:indexPath];
	Class cls = previousCommitHasSameAuthor ? DACommitMessageCell.class : DACommitCell.class;
	
	UITableViewCell<DADynamicCommitCell> *cell = [tableView dequeueCellOfClass:cls];
	
	[cell setShowsDayName:NO];
	[cell setShowsTopCellSeparator:indexPath.row > 0];
	
	[cell loadCommit:commit author:author];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedCommitIndexPath = indexPath;
	
	NSString *title = self.currentStats.dateSections[indexPath.section];
	NSArray *commits = self.currentStats.commitsOnDateSection[title];
	
	GTCommit *commit = commits[indexPath.row];
	[self presentDiffCtrlForCommit:commit];
}

@end


@implementation UITableView (RepoCtrl)

- (id)dequeueCellOfClass:(Class)cls {
	NSString *identifier = [self cellIdentifierOfClass:cls];
	return [self dequeueReusableCellWithIdentifier:identifier];
}

- (NSString *)cellIdentifierOfClass:(Class)cls {
	return cls.className;
	//	return [NSString stringWithFormat:@"%@-%@", DARepoCtrl.className, cls.className];
}

@end
