//
//  DAGitPull.m
//  Gitty
//
//  Created by kernel on 22/06/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAGitPull.h"

static int transferProgressCallback(const git_transfer_progress *progress, void *payload);

@interface DAGitPull ()
@property (strong, nonatomic) GTRepository *repo;
@property (strong, nonatomic) DAGitServer *server;
@end

@implementation DAGitPull

+ (instancetype)pullForRepository:(GTRepository *)repo fromServer:(DAGitServer *)server {
	DAGitPull *pull = self.new;
	pull.repo = repo;
	pull.server = server;
	
	return pull;
}

- (void)exec {
	int code = [self pullFromServer:self.server];
	
	if (GIT_EEXISTS == code) {
		NSDictionary *info = @{NSLocalizedDescriptionKey: @"No data pulled. Repo is up to date."};
		_completionError = [NSError errorWithDomain:@"libgit2" code:code userInfo:info];
	} else if (GIT_OK != code) {
		NSDictionary *info = @{NSLocalizedDescriptionKey: @"Failed to Pull repo.\n\nCheck your internet connection"};
		_completionError = [NSError errorWithDomain:@"libgit2" code:code userInfo:info];
	}
}

- (int)pullFromServer:(DAGitServer *)server {
	GTRemote *remote = self.repo.configuration.remotes.lastObject;
	
	git_remote *origin = remote.git_remote;
	git_remote_check_cert(remote.git_remote, 0);
	
	BOOL isSSH = [server.transferProtocol isEqualToString:SshTransferProtocol];
	git_cred_acquire_cb auth_cb = isSSH ? cred_acquire_ssh : cred_acquire_userpass;
	
	id payloadObject = nil;
	if (isSSH) {
		BOOL hasServerKeys = [DASshCredentials.manager hasSshKeypairSupportForServer:server];
		payloadObject = hasServerKeys ? server : nil;
	}
	
	git_remote_set_cred_acquire_cb(origin, auth_cb, (__bridge void *)(payloadObject));
	
	//	if (options->remote_callbacks &&
	//	    (error = git_remote_set_callbacks(origin, options->remote_callbacks)) < 0)
	//		goto on_error;
	
	git_clone_options opts = [self initOptionsForPull];
	
	return fetch_from_remote(self.repo.git_repository, remote.git_remote, &opts);
}

/*
 - (void)demoMergeFromFetchHead {
 //	GIT_MERGE_AUTOMERGE_NORMAL
 
 GTBranch *branch = nil;
 GTRepository *repo = nil;
 
 git_reference *resolved;
 int error = git_reference_resolve(&resolved, branch.reference.git_reference);
 if (0 != error) {
 [Logger error:@"err"];
 //		return error;
 }
 
 git_merge_head *head;
 error = git_merge_head_from_fetchhead(&head, repo.git_repository, branch.name.UTF8String, self.URLString.UTF8String, git_reference_target(resolved));
 if (error != 0) {
 [Logger error:@"err 2"];
 }
 
 git_reference_free(resolved);
 }*/

- (git_clone_options)initOptionsForPull {
	git_clone_options opts = [GTRepository initCloneOptions];
	
	opts.bare = 1;
	opts.transport_flags = GIT_TRANSPORTFLAGS_NO_CHECK_CERT;
	
	opts.fetch_progress_cb = transferProgressCallback;
	opts.fetch_progress_payload = (__bridge void *)self.delegate.transferProgressBlock;
	/*
	DAGitServer *server = DAServerManager.manager.list.lastObject;
	
	
	BOOL isSSH = [server.transferProtocol isEqualToString:SshTransferProtocol];
	id payloadObject = isSSH ? server : user;
	git_cred_acquire_cb auth_cb = isSSH ? cred_acquire_ssh : cred_acquire_userpass;
	
	opts.cred_acquire_cb = cred_acquire_ssh;
	opts.cred_acquire_payload = (__bridge void *)(server);
	 */
	
	return opts;
}

@end

static int transferProgressCallback(const git_transfer_progress *progress, void *payload) {
	if (!payload) {
		return 0;
	}
	
	void (^block)(const git_transfer_progress *) = (__bridge id)payload;
	block(progress);
	
	return 0;
}
