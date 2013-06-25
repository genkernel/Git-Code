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

static const NSUInteger DiffFileMaxSize = 32 * 1024;	// 32 kb.
// FIXME: design!
//static const NSUInteger SectionHeaderShadowOverlayHeight = 30.;

@interface DADiffCtrl ()
@property (strong, nonatomic, readonly) NSMutableArray *deltas;
@property (strong, nonatomic, readonly) NSMutableDictionary *deltasLineNumbers;

@property (strong, nonatomic, readonly) NSMutableDictionary *cachedViews;
@end

@implementation DADiffCtrl
@synthesize cachedViews = _cachedViews;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.changeCommit.author.name;
	self.navigationItem.prompt = self.changeCommit.messageSummary;
	
	_cachedViews = NSMutableDictionary.new;
	
	UINib *nib = [UINib nibWithNibName:DADeltaContentCell.className bundle:nil];
	[self.table registerNib:nib forCellReuseIdentifier:DADeltaContentCell.className];
	
	[NSObject startMeasurement];
	{
		[self prepareDiff];
	}
	double period = [NSObject endMeasurement];
	[Logger info:@"Diff created in %.2f.", period];
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	BOOL hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
	[self.navigationController setNavigationBarHidden:hidden];
}

- (void)prepareDiff {
	_deltas = [NSMutableArray arrayWithCapacity:1024];
	_deltasLineNumbers = [NSMutableDictionary dictionaryWithCapacity:1024];
	
	for (GTCommit *parent in self.changeCommit.parents) {
		[self compareCommit:self.changeCommit againstParentCommit:parent];
	}
}

- (void)compareCommit:(GTCommit *)commit againstParentCommit:(GTCommit *)oldCommit {
	NSError *err = nil;
	NSDictionary *opts = @{GTDiffOptionsMaxSizeKey: @(DiffFileMaxSize)};
	
	GTDiff *diff = [GTDiff diffOldTree:oldCommit.tree withNewTree:commit.tree options:opts error:&err];
	
	[diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop) {
		[self.deltas addObject:delta];
		
		[Logger info:@"delta (t:%d-b:%d-hc:%d): a:%d/d:%d/c:%d", delta.type, delta.isBinary, delta.hunkCount, delta.addedLinesCount, delta.deletedLinesCount, delta.contextLinesCount];
		
		__block NSUInteger linesCount = 0;
		
		[delta enumerateHunksWithBlock:^(GTDiffHunk *hunk, BOOL *stop) {
			[Logger info:@"  hunk (lc:%d) : %@", hunk.lineCount, hunk.header];
			
			linesCount += hunk.lineCount + 1/*header*/;
			
			[hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *line, BOOL *stop) {
				[Logger info:@"    line (o:%d %d->%d) : %@", line.origin, line.oldLineNumber, line.newLineNumber, line.content];
			}];
		}];
		
		self.deltasLineNumbers[@(self.deltas.count - 1)] = @(linesCount);
	}];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.deltas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50.;	// Original is 80px. Extra 30px overlaps cell as shadow effect.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	GTDiffDelta *delta = self.deltas[section];
	
	Class cls = GTDiffFileDeltaModified == delta.type ? DAModifiedHeader.class : DAStatusHeader.class;
	
	NSString *identifier = NSStringFromClass(cls);
	UIView *view = [self cachedViewWithIdentifier:identifier];
	if (!view) {
		view = cls.new;
	}
	
	[view performSelector:@selector(loadDelta:) withObject:delta];
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
	return GTDiffFileDeltaModified == delta.type ? 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: fetch height directly from cell instance.
	static const CGFloat lineHeight = 17.;
	
	NSUInteger linesNumber = [self.deltasLineNumbers[@(indexPath.section)] unsignedIntValue];
	linesNumber += 0 == linesNumber ? 1 : 0;
	return linesNumber * lineHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GTDiffDelta *delta = self.deltas[indexPath.section];
	
	DADeltaContentCell *cell = [tableView dequeueReusableCellWithIdentifier:DADeltaContentCell.className];
	
	[cell loadDelta:delta];
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
