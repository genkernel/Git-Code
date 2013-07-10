//
//  DAStatsCtrl.m
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatsCtrl.h"
#import "DACommitCell.h"

@interface DAStatsCtrl ()
@property (strong, nonatomic, readonly) NSDictionary *dataSource;
@end

@implementation DAStatsCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	{
		UINib *nib = [UINib nibWithNibName:DACommitCell.className bundle:nil];
		[self.commitsTable registerNib:nib forCellReuseIdentifier:DACommitCell.className];
	}
}

- (void)loadCommitsDataSource:(NSDictionary *)commits {
	_dataSource = commits;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.dataSource.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.dataSource.allKeys[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = self.dataSource.allKeys[section];
	NSArray *commits = self.dataSource[key];
	return commits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *key = self.dataSource.allKeys[indexPath.section];
	NSArray *commits = self.dataSource[key];
	GTCommit *commit = commits[indexPath.row];
	
	DACommitCell *cell = [tableView dequeueReusableCellWithIdentifier:DACommitCell.className];
	
	[cell loadCommit:commit];
	[cell setShowsTopCellSeparator:indexPath.row > 0];
	
	return cell;
}

@end
