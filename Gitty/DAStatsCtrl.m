//
//  DAStatsCtrl.m
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatsCtrl.h"
#import "DARepoCtrl.h"

#import "DAAuthorHeader.h"
#import "DATitleHeader.h"

#import "DACommitCell.h"
#import "DACommitBranchCell.h"
#import "DACommitMessageCell.h"

@interface DAStatsCtrl ()
@property (strong, nonatomic, readonly) NSDictionary *dataSource;
@property (strong, nonatomic, readonly) DARepoCtrl *repoCtrl;

@property (strong, nonatomic, readonly) DACommitBranchCell *reusableBranchCell;
@property (strong, nonatomic, readonly) DACommitCell *reusableAuthorCell;
@end

@implementation DAStatsCtrl {
	CGFloat authorHeaderHeight, branchHeaderHeight;
}
@dynamic repoCtrl;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	{
		UINib *nib = [UINib nibWithNibName:DACommitCell.className bundle:nil];
		[self.commitsTable registerNib:nib forCellReuseIdentifier:DACommitCell.className];
		
		_reusableAuthorCell = [self.commitsTable dequeueReusableCellWithIdentifier:DACommitCell.className];
	}
	{
		UINib *nib = [UINib nibWithNibName:DACommitBranchCell.className bundle:nil];
		[self.commitsTable registerNib:nib forCellReuseIdentifier:DACommitBranchCell.className];
		
		_reusableBranchCell = [self.commitsTable dequeueReusableCellWithIdentifier:DACommitBranchCell.className];
	}
	
	{
		DAAuthorHeader *header = DAAuthorHeader.new;
		authorHeaderHeight = header.height;
		[self cacheView:header withIdentifier:DAAuthorHeader.className];
	}
	{
		DATitleHeader *header = DATitleHeader.new;
		branchHeaderHeight = header.height;
		[self cacheView:header withIdentifier:DATitleHeader.className];
	}
}

- (void)loadCommitsDataSource:(NSDictionary *)commits withListMode:(DACommitsListModes)mode {
	_listMode = mode;
	_dataSource = commits;
	
	[self.commitsTable reloadData];
}

#pragma mark UITableViewDataSource helpers

- (GTCommit *)commitForIndexPath:(NSIndexPath *)indexPath {
	NSString *key = self.dataSource.allKeys[indexPath.section];
	NSArray *commits = self.dataSource[key];
	
	return commits[indexPath.row];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	BOOL isAuthorMode = DACommitsListByAuthorMode == self.listMode;
	return isAuthorMode ? authorHeaderHeight : branchHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = self.dataSource.allKeys[section];
	
	BOOL isAuthorMode = DACommitsListByAuthorMode == self.listMode;
	Class cls = isAuthorMode ? DAAuthorHeader.class : DATitleHeader.class;
	
	NSString *identifier = NSStringFromClass(cls);
	UIView *view = [self cachedViewWithIdentifier:identifier];
	if (!view) {
		view = cls.new;
	}
	
	if (isAuthorMode) {
		GTSignature *author = self.repoCtrl.authors[title];
		[((DAAuthorHeader *)view) loadAuthor:author];
	} else {
		DATitleHeader *header = (DATitleHeader *)view;
		header.nameLabel.text = title;
	}
	
	return view;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
	[self cacheView:view withIdentifier:view.className];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = self.dataSource.allKeys[section];
	NSArray *commits = self.dataSource[key];
	return commits.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	GTCommit *commit = [self commitForIndexPath:indexPath];
	
	BOOL isAuthorMode = DACommitsListByAuthorMode == self.listMode;
	
	id<DADynamicCommitCell> cell = isAuthorMode ? self.reusableBranchCell : self.reusableAuthorCell;
	
	return [cell heightForCommit:commit];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GTCommit *commit = [self commitForIndexPath:indexPath];
	
	BOOL isAuthorMode = DACommitsListByAuthorMode == self.listMode;
	
	NSString *identifier = isAuthorMode ? DACommitBranchCell.className : DACommitCell.className;
	
	UITableViewCell<DADynamicCommitCell> *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[cell loadCommit:commit];
	[cell setShowsTopCellSeparator:indexPath.row > 0];
	
	if (isAuthorMode) {
		GTBranch *branch = self.repoCtrl.branches[commit.shortSha];
		[((DACommitBranchCell *)cell) loadBranch:branch];
	}
	
	return cell;
}

#pragma mark Properties

- (DARepoCtrl *)repoCtrl {
	return (DARepoCtrl *)self.parentViewController;
}

@end
