//
//  DAGitAction+ManagerAccess.h
//  Gitty
//
//  Created by kernel on 2/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#ifndef Gitty_DAGitAction_ManagerAccess_h
#define Gitty_DAGitAction_ManagerAccess_h

@interface DAGitAction (/*Anonimous category. Do not specify name as readwrite setters fail to create. See 'readwrite' props are overriden here and setters are generated automatically. Setters are not generated if Category has name explicitly set(not anonimous). */)
@property (weak, nonatomic, readwrite) DAGitManager *manager;
@end

#endif
