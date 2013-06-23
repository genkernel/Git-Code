//
//  DACommitCell.h
//  Gitty
//
//  Created by kernel on 4/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DACommitCell : UITableViewCell
- (void)loadCommit:(GTCommit *)commit;

// Headline.
@property (strong, nonatomic) IBOutlet UILabel *shortShaLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *committerLabel;

// Content.
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *commitLabel;
@end
