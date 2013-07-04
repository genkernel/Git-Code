//
//  DACommitMessageCell.h
//  Gitty
//
//  Created by kernel on 5/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DACommitMessageCell : UITableViewCell
- (CGFloat)heightForCommit:(GTCommit *)commit;
- (void)loadCommit:(GTCommit *)commit;

- (void)setShowsTopCellSeparator:(BOOL)shows;

@property (strong, nonatomic) IBOutlet UIView *separatorLine;

@property (strong, nonatomic) IBOutlet UILabel *shortShaLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *commitLabel;
@end
