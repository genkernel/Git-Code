//
//  DADiffCtrl.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADiffCtrl.h"
// Section Headers.
#import "DAModifiedHeader.h"
#import "DAStatusHeader.h"
// Cells.
#import "DADeltaContentCell.h"

@interface DADiffCtrl ()
@property (strong, nonatomic, readonly) GTCommit *changeCommit;
@property (strong, nonatomic, readonly) NSArray *deltas;
@property (strong, nonatomic, readonly) NSDictionary *deltasHeights;
@property (strong, nonatomic, readonly) NSDictionary *deltasLongestLineWidths;

@property (strong, nonatomic, readonly) NSMutableDictionary *cachedViews;
@end

@implementation DADiffCtrl
@dynamic changeCommit, deltas, deltasHeights, deltasLongestLineWidths;

#pragma mark Properties

- (GTCommit *)changeCommit {
	return self.diff.changeCommit;
}

- (NSArray *)deltas {
	return self.diff.deltas;
}

- (NSDictionary *)deltasHeights {
	return self.diff.deltasHeights;
}

- (NSDictionary *)deltasLongestLineWidths {
	return self.diff.deltasLongestLineWidths;
}

#pragma mark VC lifecircle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.changeCommit.author.name;
	self.navigationItem.prompt = self.changeCommit.messageSummary;
	
	[self loadAuthorAvatarImage];
	
	[self.table registerClass:DADeltaContentCell.class forCellReuseIdentifier:DADeltaContentCell.className];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[DAFlurry logScreenAppear:self.className];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[DAFlurry logScreenDisappear:self.className];
}

- (void)loadAuthorAvatarImage {
	UIImageView *avatar = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"profile.png"]];
	[avatar applyAvatarStyle];
	
	[avatar setGravatarImageWithEmail:self.diff.changeCommit.author.email];
	
	UIBarButtonItem *rightButton = [UIBarButtonItem.alloc initWithCustomView:avatar];
	self.navigationItem.rightBarButtonItem = rightButton;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	BOOL hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
	[self.navigationController setNavigationBarHidden:hidden];
	
	NSString *orintation = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? WorkflowActionDiffPortrait : WorkflowActionDiffLandscape;
	[DAFlurry logWorkflowAction:orintation];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.deltas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	GTDiffDelta *delta = self.deltas[section];
	
	BOOL isModified = GTDiffFileDeltaModified == delta.type;
	
	if (isModified) {
		// DAModifiedHeader
		return 50.;	// Original is 80px. Extra 30px overlaps cell as shadow effect.
	} else {
		// DAStatusHeader.
		return 64.;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = nil;
	
//	[NSObject startMeasurement];
	{
		GTDiffDelta *delta = self.deltas[section];
		
		Class cls = GTDiffFileDeltaModified == delta.type ? DAModifiedHeader.class : DAStatusHeader.class;
		
		NSString *identifier = NSStringFromClass(cls);
		view = [self cachedViewWithIdentifier:identifier];
		if (!view) {
			view = cls.new;
		}
		
		[view performSelector:@selector(loadDelta:) withObject:delta];
	}
//	double period = [NSObject endMeasurement];
//	[Logger info:@"Header loaded in %.2f", period];
	
	return view;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
	[self cacheView:view withIdentifier:view.className];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 30.;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *view = [self cachedViewWithIdentifier:UIImageView.className];
	if (!view) {
		view = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"section_footer.png"]];
		view.backgroundColor = UIColor.clearColor;
//		[view colorizeBorderWithColor:UIColor.redColor];
	}
	return view;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
	[self cacheView:view withIdentifier:view.className];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	GTDiffDelta *delta = self.deltas[section];
	
	BOOL isModified = GTDiffFileDeltaModified == delta.type;
	BOOL isAdded = GTDiffFileDeltaAdded == delta.type;
	
	return isModified || isAdded ? 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self.deltasHeights[@(indexPath.section)] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DADeltaContentCell *cell = nil;
	
	//[NSObject startMeasurement];
	{
		GTDiffDelta *delta = self.deltas[indexPath.section];
		
		cell = [tableView dequeueReusableCellWithIdentifier:DADeltaContentCell.className];
		
		CGFloat longestLineWidth = [self.deltasLongestLineWidths[@(indexPath.section)] floatValue];
		
		[cell loadDelta:delta withLongestLineOfWidth:longestLineWidth];
	}
	//double period = [NSObject endMeasurement];
	//[Logger info:@"Cell loaded in %.2f", period];
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
