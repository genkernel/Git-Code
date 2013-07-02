//
//  DANewServer.h
//  Gitty
//
//  Created by kernel on 17/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DANewServerCtrl : DABaseCtrl <UITextFieldDelegate>
- (void)resetFields;
- (void)disableFeatureWithNotice:(NSString *)message;

@property (strong, nonatomic) IBOutlet UILabel *noticeLabel;
@property (strong, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IBOutlet UITextField *serverUrlField, *serverNameField;
@end
