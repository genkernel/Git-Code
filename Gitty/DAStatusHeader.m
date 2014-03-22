//
//  DAModifiedHeader.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAStatusHeader.h"

@interface DAStatusHeader ()
@property (strong, nonatomic, readonly) NSArray *titles;

@property (strong, nonatomic, readonly) UIToolbar *bluringToolbar;
@end

@implementation DAStatusHeader
@dynamic titles;

- (id)init {
    self = [super init];
    if (self) {
		NSArray *views = [NSBundle.mainBundle loadNibNamed:self.className owner:self options:nil];
		
		UIView *view = views[0];
		self.frame = view.bounds;
		
		[self addSubview:view];
		
		view.translatesAutoresizingMaskIntoConstraints = NO;
		[view applyFullscreenConstraints];
		
		[self applyLightEffectOnBackground];
    }
    return self;
}

- (void)applyLightEffectOnBackground {
	_bluringToolbar = [UIToolbar.alloc initWithFrame:self.bluringBackground.bounds];
	
	[self.bluringBackground addSubview:self.bluringToolbar];
	self.bluringToolbar.translatesAutoresizingMaskIntoConstraints = NO;
	[self.bluringToolbar applyFullscreenConstraints];
	
	self.bluringToolbar.translucent = YES;
	self.bluringToolbar.barTintColor = UIColor.blackColor;
	
//	[self.bluringBackground.layer insertSublayer:self.bluringToolbar.layer atIndex:0];
}

- (NSString *)titleForChangeType:(GTDiffDeltaType)type {
	if (type >= self.titles.count) {
		return nil;
	}
	return self.titles[type];
}

- (void)loadDelta:(GTDiffDelta *)delta {
	self.statusLabel.hidden = NO;
	self.statusLabel.text = [self titleForChangeType:delta.type];
	
	if (GTDiffFileDeltaAdded == delta.type) {
#warning revamp
//		self.statusLabel.hidden = !delta.isBinary;
		
		self.symbolLabel.text = nil;
		self.filenameLabel.text = nil;
		
		self.anotherSymbolLabel.textColor = UIColor.acceptingGreenColor;
		self.anotherFilenameLabel.textColor = UIColor.acceptingGreenColor;
		
		self.anotherSymbolLabel.text = @"+";
		self.anotherFilenameLabel.text = delta.newFile.path;
		
	} else if (GTDiffFileDeltaDeleted == delta.type) {
		self.symbolLabel.textColor = UIColor.cancelingRedColor;
		self.filenameLabel.textColor = UIColor.cancelingRedColor;
		
		self.symbolLabel.text = @"-";
		self.filenameLabel.text = delta.oldFile.path;
		
		self.anotherSymbolLabel.text = nil;
		self.anotherFilenameLabel.text = nil;
	} else if (GTDiffFileDeltaRenamed == delta.type) {
		self.symbolLabel.textColor = UIColor.lightGrayColor;
		self.filenameLabel.textColor = UIColor.lightGrayColor;
		
		self.anotherSymbolLabel.textColor = UIColor.whiteColor;
		self.anotherFilenameLabel.textColor = UIColor.whiteColor;
		
		self.symbolLabel.text = nil;
		self.filenameLabel.text = delta.oldFile.path;
		
		self.anotherSymbolLabel.text = @"➟";
		self.anotherFilenameLabel.text = delta.newFile.path;
		
	} else if (GTDiffFileDeltaCopied == delta.type) {
		self.symbolLabel.textColor = UIColor.whiteColor;
		self.filenameLabel.textColor = UIColor.whiteColor;
		
		self.anotherSymbolLabel.textColor = UIColor.acceptingGreenColor;
		self.anotherFilenameLabel.textColor = UIColor.acceptingGreenColor;
		
		self.symbolLabel.text = nil;
		self.filenameLabel.text = delta.oldFile.path;
		
		self.anotherSymbolLabel.text = @"+";
		self.anotherFilenameLabel.text = delta.newFile.path;
		
	} else {
		self.symbolLabel.textColor = UIColor.whiteColor;
		self.filenameLabel.textColor = UIColor.whiteColor;
		
		self.anotherSymbolLabel.textColor = UIColor.lightGrayColor;
		self.anotherFilenameLabel.textColor = UIColor.lightGrayColor;
		
		self.symbolLabel.text = nil;
		self.filenameLabel.text = delta.oldFile.path;
		
		self.anotherSymbolLabel.text = nil;
		self.anotherFilenameLabel.text = delta.newFile.path;
	}
}

#pragma mark Properties

- (NSArray *)titles {
	static NSArray *titles = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// Strict GTDiffDeltaType ordering.
		titles = @[NSLocalizedString(@"Unmodified", nil),
			  NSLocalizedString(@"New file", nil),
			  NSLocalizedString(@"Deleted", nil),
			  NSLocalizedString(@"Modified", nil),
			  NSLocalizedString(@"Renamed", nil),
			  NSLocalizedString(@"Copied", nil),
			  NSLocalizedString(@"Ignored", nil),
			  NSLocalizedString(@"Untracked", nil),
			  NSLocalizedString(@"Type changed", nil)];
	});
	return titles;
}

@end
