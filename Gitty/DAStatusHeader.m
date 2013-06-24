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
@end

@implementation DAStatusHeader
@dynamic titles;

- (id)init
{
    self = [super init];
    if (self) {
		NSArray *views = [NSBundle.mainBundle loadNibNamed:self.className owner:self options:nil];
		
		UIView *view = views[0];
		self.frame = view.bounds;
		
		[self addSubview:view];
    }
    return self;
}

- (NSString *)titleForChangeType:(GTDiffDeltaType)type {
	if (type >= self.titles.count) {
		return nil;
	}
	return self.titles[type];
}

- (NSString *)shortFilePathFromFullPath:(NSString *)fullPath {
	static const int PathMaxCharactersCount = 22;
	NSString *path = fullPath.lastPathComponent;
	
	NSArray *components = fullPath.pathComponents;
	int i = components.count - 2;
	for (; i >= 0 && i < components.count; i--) {
		NSString *part = components[i];
		if (part.length + path.length + 1 > PathMaxCharactersCount) {
			break;
		}
		path = [part stringByAppendingPathComponent:path];
	}
	
	BOOL hasMoreComponents = i > 0;
	if (components.count > 1 && hasMoreComponents) {
		return [NSString stringWithFormat:@".../%@", path];
	} else {
		return path;
	}
}

- (void)loadDelta:(GTDiffDelta *)delta {
	self.statusLabel.text = [self titleForChangeType:delta.type];
	
	if (GTDiffFileDeltaAdded == delta.type) {
		self.anotherFilenameLabel.textColor = UIColor.acceptingGreenColor;
		
		self.filenameLabel.text = nil;
		
		NSString *path = [self shortFilePathFromFullPath:delta.newFile.path];
		self.anotherFilenameLabel.text = [NSString stringWithFormat:@"+ %@", path];
		
	} else if (GTDiffFileDeltaDeleted == delta.type) {
		self.filenameLabel.textColor = UIColor.cancelingRedColor;
		
		NSString *path = [self shortFilePathFromFullPath:delta.oldFile.path];
		self.filenameLabel.text = [NSString stringWithFormat:@"- %@", path];
		
		self.anotherFilenameLabel.text = nil;
	} else if (GTDiffFileDeltaRenamed == delta.type) {
		self.filenameLabel.textColor = UIColor.lightGrayColor;
		self.anotherFilenameLabel.textColor = UIColor.whiteColor;
		
		self.filenameLabel.text = [self shortFilePathFromFullPath:delta.oldFile.path];
		
		NSString *path = [self shortFilePathFromFullPath:delta.newFile.path];
		self.anotherFilenameLabel.text = [NSString stringWithFormat:@"➟ %@", path];
		
	} else if (GTDiffFileDeltaCopied == delta.type) {
		self.filenameLabel.textColor = UIColor.whiteColor;
		self.filenameLabel.textColor = UIColor.acceptingGreenColor;
		
		self.filenameLabel.text = [self shortFilePathFromFullPath:delta.oldFile.path];
		
		NSString *path = [self shortFilePathFromFullPath:delta.newFile.path];
		self.anotherFilenameLabel.text = [NSString stringWithFormat:@"+ %@", path];
		
	} else {
		self.filenameLabel.textColor = UIColor.whiteColor;
		self.anotherFilenameLabel.textColor = UIColor.lightGrayColor;
		
		self.filenameLabel.text = [self shortFilePathFromFullPath:delta.oldFile.path];
		self.anotherFilenameLabel.text = [self shortFilePathFromFullPath:delta.newFile.path];
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
