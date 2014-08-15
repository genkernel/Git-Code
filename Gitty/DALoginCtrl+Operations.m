//
//  DALoginCtrl+Operations.m
//  Git Code
//
//  Created by Altukhov Anton on 8/15/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

#import "DALoginCtrl+Operations.h"

@implementation DALoginCtrl (Operations)

- (void)deleteServer:(DAGitServer *)server {
	for (NSDictionary *repo in server.repos.allValues) {
		[server removeRecentRepoByRelativePath:repo.relativePath];
		
		[self.git removeExistingRepo:repo.relativePath forServer:server];
	}
	
	[self.servers removeExistingServer:server];
}

@end
