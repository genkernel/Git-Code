//
//  GTRepository+Gitty.h
//  Gitty
//
//  Created by Shawn Altukhov on 23/03/2014.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

@interface GTRepository (Gitty)
- (BOOL)pullFromRemote:(GTRemote *)_remote credentials:(GTCredentialProvider *)credentialProvider;
@end
