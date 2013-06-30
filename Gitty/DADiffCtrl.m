//
//  DADiffCtrl.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADiffCtrl.h"
#import "DADiffCtrl+UI.h"
// Section Headers.
#import "DAModifiedHeader.h"
#import "DAStatusHeader.h"
// Cells.
#import "DADeltaContentCell.h"

// FIXME: design!
//static const NSUInteger SectionHeaderShadowOverlayHeight = 30.;

@interface DADiffCtrl ()
@property (strong, nonatomic, readonly) GTCommit *changeCommit;
@property (strong, nonatomic, readonly) NSArray *deltas;
@property (strong, nonatomic, readonly) NSDictionary *deltasHeights;

@property (strong, nonatomic, readonly) NSMutableDictionary *cachedViews;
@end

@implementation DADiffCtrl
@synthesize cachedViews = _cachedViews;
@dynamic changeCommit, deltas, deltasHeights;

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

#pragma mark VC lifecircle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.changeCommit.author.name;
	self.navigationItem.prompt = self.changeCommit.messageSummary;
	
	_cachedViews = NSMutableDictionary.new;
	
	[self.table registerClass:DADeltaContentCell.class forCellReuseIdentifier:DADeltaContentCell.className];
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	BOOL hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
	[self.navigationController setNavigationBarHidden:hidden];
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
		return 38.;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = nil;
	
	[NSObject startMeasurement];
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
	double period = [NSObject endMeasurement];
	[Logger info:@"Header loaded in %.2f", period];
	
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
		
		[cell loadDelta:delta];
	}
	//double period = [NSObject endMeasurement];
	//[Logger info:@"Cell loaded in %.2f", period];
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
