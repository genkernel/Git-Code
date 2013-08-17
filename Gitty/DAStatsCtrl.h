//
//  DAStatsCtrl.h
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"
#import "DAByAuthorDataSource.h"
#import "DAByBranchDataSource.h"

@interface DAStatsCtrl : DABaseCtrl {
	BOOL _isByBranchTableVisible;
}
- (void)reloadData;

@property (nonatomic, readonly) BOOL isByBranchTableVisible;
@property () BOOL isShowingCommitsOfMultipleDays;

@property (strong, nonatomic) NSString *headlineSinceDayText;

// Header.
@property (strong, nonatomic) IBOutlet UIView *headerContainer;
@property (strong, nonatomic) IBOutlet UILabel *headlineLabel, *noCommitsLabel;

// commitsTable is @dynamic and points to visible table: byAuthorTable or byBranchTable.
@property (strong, nonatomic, readonly) UITableView *commitsTable;
@property (strong, nonatomic) IBOutlet UITableView *byAuthorTable, *byBranchTable;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *byAuthorTableLeft;

@property (strong, nonatomic) IBOutlet UIView *commitsContainer;

@property (strong, nonatomic) IBOutlet TreeTable *byAuthorProxy, *byBranchProxy;


@property (strong, nonatomic) IBOutlet DAByAuthorDataSource *byAuthorDataSource;
@property (strong, nonatomic) IBOutlet DAByBranchDataSource *byBranchDataSource;
@end
