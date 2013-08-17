//
//  DAStatsDataSource.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatsDataSource.h"

@interface DAStatsDataSource ()
@property (strong, nonatomic, readonly) NSMutableSet *closedItems;
@end

@implementation DAStatsDataSource

- (id)init {
	self = [super init];
	if (self) {
		_closedItems = NSMutableSet.new;
	}
	return self;
}

#pragma mark Helper methods

- (GTCommit *)commitForIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath indexAtPosition:1];
	NSUInteger row = [indexPath indexAtPosition:2];
	
	NSString *key = self.commits.allKeys[section];
	NSArray *commits = self.commits[key];
	
	return commits[row];
}

// Commit is Subsequent when its previous commit is prepared by the same Author (in the very same Day).
- (BOOL)isSubsequentCommitAtIndexPath:(NSIndexPath *)indexPath {
	NSString *key = self.commits.allKeys[indexPath.section];
	NSArray *commits = self.commits[key];
	
	NSUInteger idx = indexPath.row;
	GTCommit *commit = commits[idx];
	
	BOOL previousCommitHasSameAuthor = NO;
	
	BOOL hasPreviousCommitInSection = idx > 0;
	if (hasPreviousCommitInSection) {
		GTCommit *prevCommit = commits[idx - 1];
		
		previousCommitHasSameAuthor = [commit.author isEqual:prevCommit.author];
//		previousCommitHasSameAuthor = [commit.author.name isEqualToString:prevCommit.author.name] && [commit.author.email isEqualToString:prevCommit.author.email];
	}
	
	return previousCommitHasSameAuthor;
}

- (void)treeView:(TreeTable *)proxy toggleCellAtIndexPath:(NSIndexPath *)ip {
	if ([self.closedItems containsObject:ip]) {
		[self.closedItems removeObject:ip];
		
		[proxy expand:ip];
	} else {
		[self.closedItems addObject:ip];
		
		[proxy close:ip];
	}
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView isCellExpanded:(NSIndexPath *)indexPath {
	return ![self.closedItems containsObject:indexPath];
}

- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.length != 2) {
		return 0;
	}
	
	NSString *key = self.commits.allKeys[indexPath.section];
	NSArray *commits = self.commits[key];
	return commits.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.commits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSAssert(NO, @"Impl in subclass.");
	return nil;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return headerHeight;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
	[self cacheView:view withIdentifier:view.className];
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TreeTable *proxy = tableView.dataSource;
	NSIndexPath *ip = [proxy treeIndexPathFromTablePath:indexPath];
	
	if (ip.length == 3) {
		self.selectCellAction(self, ip);
		return;
	}
	
	[self treeView:proxy toggleCellAtIndexPath:ip];
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
