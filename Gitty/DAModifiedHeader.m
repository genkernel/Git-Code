//
//  DAModifiedHeader.m
//  Gitty
//
//  Created by kernel on 5/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAModifiedHeader.h"

@interface DAModifiedHeader ()
@property (strong, nonatomic, readonly) UIToolbar *bluringToolbar;
@end

@implementation DAModifiedHeader

- (id)init {
    self = [super init];
    if (self) {
		NSArray *views = [NSBundle.mainBundle loadNibNamed:self.className owner:self options:nil];
		
		UIView *view = views[0];
		self.frame = view.bounds;
		
		[self addSubview:view];
		
		[self applyLightEffectOnBackground];
		
//		[view colorizeBorderWithColor:UIColor.blueColor];
    }
    return self;
}

- (void)applyLightEffectOnBackground {
	_bluringToolbar = [UIToolbar.alloc initWithFrame:self.bluringBackground.bounds];
	
	self.bluringToolbar.translucent = YES;
	self.bluringToolbar.barTintColor = UIColor.blackColor;
	
	[self.bluringBackground.layer insertSublayer:self.bluringToolbar.layer atIndex:0];
}

- (void)loadDelta:(GTDiffDelta *)delta {
	self.graph.delta = delta;
	
	self.filenameLabel.text = delta.newFile.path;
	
	NSString *fmt = 1 == delta.addedLinesCount ? @"%d addition" : @"%d additions";
	self.additionsLabel.text = [NSString stringWithFormat:fmt, delta.addedLinesCount];
	
	fmt = 1 == delta.deletedLinesCount ? @"%d deletion" : @"%d deletions";
	self.deletionsLabel.text = [NSString stringWithFormat:fmt, delta.deletedLinesCount];
	
	self.additionsLabel.hidden = delta.isBinary;
	self.deletionsLabel.hidden = delta.isBinary;
	self.binaryStatusLabel.hidden = !delta.isBinary;
}

@end
