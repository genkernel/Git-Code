//
//  DADiffCtrlDataSource.h
//  Gitty
//
//  Created by kernel on 26/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DADiffCtrlDataSource : NSObject
+ (instancetype)loadDiffForCommit:(GTCommit *)commit;

@property (strong, nonatomic, readonly) GTCommit *changeCommit;
@property (strong, nonatomic, readonly) NSMutableArray *deltas;
@property (strong, nonatomic, readonly) NSMutableDictionary *deltasHeights;
@end
