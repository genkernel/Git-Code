//
//  GTDiffDelta+Gitty.m
//  Gitty
//
//  Created by Shawn Altukhov on 23/03/2014.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "GTDiffDelta+Gitty.h"

@implementation GTDiffDelta (Gitty)
@dynamic isBinary;

- (BOOL)isBinary {
	return self.flags == GTDiffFileFlagBinary;
}

@end
