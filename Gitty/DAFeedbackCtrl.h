//
//  DAFeedbackCtrl.h
//  Gitty
//
//  Created by kernel on 27/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DABaseCtrl.h"

@interface DAFeedbackCtrl : DABaseCtrl <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
