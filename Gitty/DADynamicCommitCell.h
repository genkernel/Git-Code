//
//  DADynamicCommitCell.h
//  Gitty
//
//  Created by kernel on 12/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#ifndef Gitty_DADynamicCommitCell_h
#define Gitty_DADynamicCommitCell_h

@protocol DADynamicCommitCell <NSObject>
@required
- (CGFloat)heightForCommit:(GTCommit *)commit;
- (void)loadCommit:(GTCommit *)commit;
- (void)setShowsTopCellSeparator:(BOOL)shows;
@end

#endif
