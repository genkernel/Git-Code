//
//  DASshCredentials.h
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DASshCredentials : NSObject
+ (instancetype)manager;

@property (strong, nonatomic, readonly) NSString *publicKeyPath, *privateKeyPath, *passphrase;
@end
