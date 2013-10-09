//
//  DAQuickRepoCell.h
//  Gitty
//
//  Created by kernel on 4/10/2013.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAQuickRepoCell : UITableViewCell
- (void)loadRepo:(NSDictionary *)repo active:(BOOL)active;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logo;
@end
