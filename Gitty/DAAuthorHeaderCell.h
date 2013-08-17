//
//  DAAuthorHeader.h
//  Gitty
//
//  Created by kernel on 12/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAAuthorHeaderCell : UITableViewCell
- (void)loadAuthor:(GTSignature *)author;

@property (nonatomic) BOOL collapsed;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;
@end
