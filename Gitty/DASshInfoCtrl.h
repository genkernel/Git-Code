//
//  DASshInfoCtrl.h
//  Gitty
//
//  Created by kernel on 26/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DASshInfoCtrl : DABaseCtrl <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
