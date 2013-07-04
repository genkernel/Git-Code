//
//  DACommitCell.h
//  Gitty
//
//  Created by kernel on 4/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DACommitMessageCell.h"

@interface DACommitCell : DACommitMessageCell
- (CGFloat)heightForCommit:(GTCommit *)commit;
- (void)loadCommit:(GTCommit *)commit;

// Author Headline.
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@end
