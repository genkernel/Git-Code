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
@property (strong, nonatomic, readwrite) GTRepository *repo;
@end

@implementation DADiffCtrlDataSource

+ (instancetype)loadDiffForCommit:(GTCommit *)commit inRepo:(GTRepository *)repo {
	DADiffCtrlDataSource *diff = self.new;
	diff.repo = repo;
	
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
	[LLog info:@"Diff created in %.2f.", period];
}

- (void)prepareDiff {
	_deltasHeights = NSMutableDictionary.new;
	_deltasLongestLineWidths = NSMutableDictionary.new;
	_deltas = [NSMutableArray arrayWithCapacity:1024];
	
	BOOL isFirstInitialCommit = 0 == self.changeCommit.parents.count;
	if (isFirstInitialCommit) {
		[LLog info:@"Preparing Diff for First(initial) commit."];
		[self compareCommit:self.changeCommit againstParentCommit:nil];
	} else {
		for (GTCommit *parent in self.changeCommit.parents) {
			[self compareCommit:self.changeCommit againstParentCommit:parent];
		}
	}
}

- (NSDictionary *)attributesWithFont:(UIFont *)font {
	NSMutableDictionary *attributes = @{}.mutableCopy;
	
	attributes[NSFontAttributeName] = font;
	
	return attributes;
}


- (void)compareCommit:(GTCommit *)commit againstParentCommit:(GTCommit *)oldCommit {
	// TODO: fetch font directly from corresponding view.
	UIFont *font = [UIFont fontWithName:@"Courier" size:14.];
	
	NSDictionary *attributes = [self attributesWithFont:font];
	
	const CGFloat lineHeight = font.lineHeight;
	
	NSError *err = nil;
	NSDictionary *opts = @{GTDiffOptionsMaxSizeKey: @(DiffFileMaxSize)};
	
	GTDiff *diff = [GTDiff diffOldTree:oldCommit.tree withNewTree:commit.tree inRepository:self.repo options:opts error:&err];
	
	[diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop) {
		[self.deltas addObject:delta];
		
		//[LLog info:@"delta (t:%d-b:%d-hc:%d): a:%d/d:%d/c:%d", delta.type, delta.isBinary, delta.hunkCount, delta.addedLinesCount, delta.deletedLinesCount, delta.contextLinesCount];
		
		__block NSUInteger linesCount = 0;
		__block CGFloat longestLineWidth = .0;
		
		GTDiffPatch *patch = [delta generatePatch:nil];
		
		NSMutableArray *hunks = [NSMutableArray arrayWithCapacity:patch.hunkCount];
		
		[patch enumerateHunksUsingBlock:^(GTDiffHunk *hunk, BOOL *stop) {
			//[LLog info:@"  hunk (lc:%d) : %@", hunk.lineCount, hunk.header];
			[hunks addObject:hunk];
			
			linesCount += hunk.lineCount + 1/*header*/;
			
			NSError *err = nil;
			[hunk enumerateLinesInHunk:&err usingBlock:^(GTDiffLine *line, BOOL *stop) {
				CGSize maxSize = CGSizeMake(4096, 4096);
				CGRect r = [line.content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
				
				longestLineWidth = MAX(r.size.width, longestLineWidth);
			}];
		}];
		
		NSUInteger hunkCount = patch.hunkCount > 0 ? patch.hunkCount - 1 : 0;
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
