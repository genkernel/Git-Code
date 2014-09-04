//
//  WMBlockedCountryWindow.h
//  Sidus
//
//  Created by Altukhov Anton on 9/3/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMGeoBlockerWindow : UIWindow
+ (void)checkCurrentCountry;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@end
