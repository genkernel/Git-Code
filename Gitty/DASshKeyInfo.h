//
//  DASshKeyInfo.h
//  Gitty
//
//  Created by kernel on 14/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitServer.h"
#import "DASshKeyInfoConfig.h"

typedef AlertQueue DAAlertQueue;
typedef Alert DAAlert;

extern NSString *DASSHKeysStateChanged;

@interface DASshKeyInfo : NSObject <UIAlertViewDelegate>
+ (instancetype)keysInfoForServer:(DAGitServer *)server;

@property (strong, nonatomic, readonly) NSString *username, *passphrase;
@property (strong, nonatomic, readonly) NSString *publicKeyPath, *privateKeyPath;
@end
