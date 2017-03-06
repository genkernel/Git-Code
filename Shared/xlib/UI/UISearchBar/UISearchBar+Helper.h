//
//  UISearchBar+Helper.h
//  WiFi Music
//
//  Created by Shawn Altukhov on 11/06/2014.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "UIView+Helper.h"

@interface UISearchBar (Helper)// <UITextInputTraits> - iOS7
- (void)enableAllControlButtons;

@property (strong, nonatomic, readonly) UITextField *textField;
@end
