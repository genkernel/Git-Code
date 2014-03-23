//
//  GTRepository+Gitty.h
//  Gitty
//
//  Created by Shawn Altukhov on 23/03/2014.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import <ObjectiveGit/ObjectiveGit.h>

@interface GTRepository (Gitty)
- (void)pullFromRemote:(GTRemote *)_remote credentials:(GTCredentialProvider *)credentialProvider;
@end
