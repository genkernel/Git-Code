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
// Cells.
#import "DADeltaContentCell.h"

static const NSUInteger DiffFileMaxSize = 32 * 1024;	// 32 kb.

@interface DADiffCtrl ()
@property (strong, nonatomic, readonly) NSArray *deltas;
@property (strong, nonatomic, readonly) NSDictionary *deltasLineNumbers;

@property (strong, nonatomic, readonly) NSMutableSet *cachedHeaders, *cachedFooters;
@end

@implementation DADiffCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_cachedHeaders = NSMutableSet.set;
	_cachedFooters = NSMutableSet.set;
	
	UINib *nib = [UINib nibWithNibName:DADeltaContentCell.className bundle:nil];
	[self.table registerNib:nib forCellReuseIdentifier:DADeltaContentCell.className];
	
	[NSObject startMeasurement];
	{
		[self prepareDiff];
	}
	double period = [NSObject endMeasurement];
	[Logger info:@"Diff created in %.2f.", period];
}

- (void)prepareDiff {
	NSError *err = nil;
	NSDictionary *opts = @{GTDiffOptionsMaxSizeKey: @(DiffFileMaxSize)};
	
	GTDiff *diff = [GTDiff diffOldTree:self.previousCommit.tree withNewTree:self.changeCommit.tree options:opts error:&err];
	
	NSMutableArray *deltas = [NSMutableArray arrayWithCapacity:200];
	NSMutableDictionary *lineNumbers = [NSMutableDictionary dictionaryWithCapacity:200];
	
	[diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop) {
		[deltas addObject:delta];
		
		[Logger info:@"delta (t:%d-b:%d-hc:%d): a:%d/d:%d/c:%d", delta.type, delta.isBinary, delta.hunkCount, delta.addedLinesCount, delta.deletedLinesCount, delta.contextLinesCount];
		
		__block NSUInteger linesCount = 1;
		
		[delta enumerateHunksWithBlock:^(GTDiffHunk *hunk, BOOL *stop) {
			[Logger info:@"  hunk (lc:%d) : %@", hunk.lineCount, hunk.header];
			
			linesCount += hunk.lineCount;
			
			[hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *line, BOOL *stop) {
				[Logger info:@"    line (o:%d %d->%d) : %@", line.origin, line.oldLineNumber, line.newLineNumber, line.content];
			}];
		}];
		
		lineNumbers[@(deltas.count - 1)] = @(linesCount);
	}];
	
	_deltas = [NSArray arrayWithArray:deltas];
	_deltasLineNumbers = [NSDictionary dictionaryWithDictionary:lineNumbers];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.deltas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50.;	// Original is 80px. Extra 30px overlaps cell as shadow effect.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	DAModifiedHeader *view = nil;
	
	if (self.cachedHeaders.count) {
		// Reuse cached view.
		view = self.cachedHeaders.anyObject;
		[self.cachedHeaders removeObject:view];
	} else {
		view = DAModifiedHeader.new;
	}
	
	[view loadDelta:self.deltas[section]];
	return view;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
	[self.cachedHeaders addObject:view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 30.;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIImageView *view = nil;
	
	if (self.cachedFooters.count) {
		// Reuse cached view.
		view = self.cachedFooters.anyObject;
		[self.cachedFooters removeObject:view];
	} else {
		view = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"section_footer.png"]];
	}
	
	return view;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
	[self.cachedFooters addObject:view];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger linesNumber = [self.deltasLineNumbers[@(indexPath.section)] unsignedIntValue];
	return (1 + linesNumber) * 17. + 5.;
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
