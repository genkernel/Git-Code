//
//  DASshKeyInfo.h
//  Gitty
//
//  Created by kernel on 14/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitServer.h"

@interface DASshKeyInfo : NSObject <UIAlertViewDelegate>
//+ (instancetype)globalKeysInfo;
+ (instancetype)keysInfoForServer:(DAGitServer *)server;

@property (strong, nonatomic, readonly) NSString *publicKeyPath, *privateKeyPath, *passphrase;
@end
