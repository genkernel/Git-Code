//
//  DAStatsDataSource.m
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatsDataSource.h"

#import "DACommitCell.h"
#import "DACommitBranchCell.h"
#import "DACommitMessageCell.h"

@implementation DAStatsDataSource

- (id)init {
	self = [super init];
	if (self) {
		_closedItems = NSMutableSet.new;
	}
	return self;
}

- (void)setupForTableView:(UITableView *)tableView {
	NSArray *cells = @[DACommitCell.className, DACommitMessageCell.className, DACommitBranchCell.className];
	
	for (NSString *className in cells) {
		UINib *nib = [UINib nibWithNibName:className bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:className];
	}
}

#pragma mark Helper methods

- (GTCommit *)commitForIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath indexAtPosition:1];
	NSUInteger row = [indexPath indexAtPosition:2];
	
	NSString *key = self.commits.allKeys[section];
	NSArray *commits = self.commits[key];
	
	return commits[row];
}

- (BOOL)treeView:(TreeTable *)proxy toggleCellAtIndexPath:(NSIndexPath *)indexPath treeIndexPath:(NSIndexPath *)ip {
	if ([self.closedItems containsObject:ip]) {
		[self.closedItems removeObject:ip];
		
		[proxy expand:ip];
		return YES;
	} else {
		[self.closedItems addObject:ip];
		
		[proxy close:ip];
		return NO;
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
	
	NSString *key = self.commits.allKeys[indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TreeTable *proxy = tableView.dataSource;
	NSIndexPath *ip = [proxy treeIndexPathFromTablePath:indexPath];
	
	if (ip.length == 3) {
		self.selectCellAction(self, ip);
		return;
	}
	
	BOOL isJustExpandedCell = [self treeView:proxy toggleCellAtIndexPath:indexPath treeIndexPath:ip];
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (isJustExpandedCell) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
		});
	}
}

@end
