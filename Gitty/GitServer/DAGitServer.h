//
//  DAGitServer.h
//  Gitty
//
//  Created by kernel on 30/11/12.
//  Copyright (c) 2012 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAGitServer : NSObject
+ (instancetype)serverWithDictionary:(NSDictionary *)dict;

@property (strong, nonatomic, readonly) NSDictionary *saveDict;

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *gitBaseUrl;
@property (strong, nonatomic) NSString *transferProtocol;
@property (strong, nonatomic, readonly) NSArray *supportedProtocols;
@property (strong, nonatomic, readonly) NSString *saveDirectoryName;
@property (strong, nonatomic, readonly) NSString *logoIconName;
@end
