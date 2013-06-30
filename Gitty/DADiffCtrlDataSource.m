//
//  DADiffCtrlDataSource.m
//  Gitty
//
//  Created by kernel on 26/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DADiffCtrlDataSource.h"

static const NSUInteger DiffFileMaxSize = 32 * 1024;	// 32 kb.

@interface DADiffCtrlDataSource ()
@property (strong, nonatomic, readwrite) GTCommit *changeCommit;
@end

@implementation DADiffCtrlDataSource

+ (instancetype)loadDiffForCommit:(GTCommit *)commit {
	DADiffCtrlDataSource *diff = self.new;
	[diff loadDiffForCommit:commit];
	return diff;
}

- (void)loadDiffForCommit:(GTCommit *)commit {
	_changeCommit = commit;
	
	[NSObject startMeasurement];
	{
		[self prepareDiff];
	}
	double period = [NSObject endMeasurement];
	[Logger info:@"Diff created in %.2f.", period];
}

- (void)prepareDiff {
	_deltasHeights = NSMutableDictionary.new;
	_deltasLongestLineWidths = NSMutableDictionary.new;
	_deltas = [NSMutableArray arrayWithCapacity:1024];
	
	BOOL isFirstInitialCommit = 0 == self.changeCommit.parents.count;
	if (isFirstInitialCommit) {
		[Logger info:@"Preparing Diff for First(initial) commit."];
		[self compareCommit:self.changeCommit againstParentCommit:nil];
	} else {
		for (GTCommit *parent in self.changeCommit.parents) {
			[self compareCommit:self.changeCommit againstParentCommit:parent];
		}
	}
}

- (void)compareCommit:(GTCommit *)commit againstParentCommit:(GTCommit *)oldCommit {
	// TODO: fetch font directly from corresponding view.
	UIFont *font = [UIFont fontWithName:@"Courier" size:14.];
	NSLineBreakMode lineBreakMode = NSLineBreakByClipping;
	
	const CGFloat lineHeight = font.lineHeight;
	
	NSError *err = nil;
	NSDictionary *opts = @{GTDiffOptionsMaxSizeKey: @(DiffFileMaxSize)};
	
	GTDiff *diff = [GTDiff diffOldTree:oldCommit.tree withNewTree:commit.tree options:opts error:&err];
	
	[diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop) {
		[self.deltas addObject:delta];
		
		//[Logger info:@"delta (t:%d-b:%d-hc:%d): a:%d/d:%d/c:%d", delta.type, delta.isBinary, delta.hunkCount, delta.addedLinesCount, delta.deletedLinesCount, delta.contextLinesCount];
		
		__block NSUInteger linesCount = 0;
		__block CGFloat longestLineWidth = .0;
		
		NSMutableArray *hunks = [NSMutableArray arrayWithCapacity:delta.hunkCount];
		
		[delta enumerateHunksWithBlock:^(GTDiffHunk *hunk, BOOL *stop) {
			//[Logger info:@"  hunk (lc:%d) : %@", hunk.lineCount, hunk.header];
			[hunks addObject:hunk];
			
			linesCount += hunk.lineCount + 1/*header*/;
			
			[hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *line, BOOL *stop) {
				CGSize s = [line.content sizeWithFont:font forWidth:4096. lineBreakMode:lineBreakMode];
				
				longestLineWidth = MAX(s.width, longestLineWidth);
			}];
		}];
		
		delta.hunks = hunks;
		
		NSUInteger hunkCount = delta.hunkCount > 0 ? delta.hunkCount - 1 : 0;
		// TODO: get separator view height directly from owning view.
		CGFloat separatorHeight = 21.;
		
		NSUInteger linesNumber = 0 == linesCount ? 1 : linesCount;
		CGFloat height = linesNumber * lineHeight + hunkCount * separatorHeight;
		
		NSNumber *lineNumber = @(self.deltas.count - 1);
		
		self.deltasHeights[lineNumber] = @(height);
		self.deltasLongestLineWidths[lineNumber] = @(longestLineWidth);
	}];
}

@end