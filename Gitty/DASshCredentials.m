//
//  DASshCredentials.m
//  Gitty
//
//  Created by kernel on 9/07/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASshCredentials.h"

static NSString *ZipExtension = @"zip";

@interface DASshCredentials ()
@property (strong, nonatomic, readonly) UIApplication *app;
@property (strong, nonatomic, readonly) DAAlertQueue *alert;

@property (strong, nonatomic, readonly) NSMutableDictionary *cachedServerKeys;
@end

@implementation DASshCredentials
@dynamic app, alert;

+ (instancetype)manager {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	return instance;
}

- (id)init {
	self = [super init];
	if (self) {
		_cachedServerKeys = NSMutableDictionary.new;
	}
	return self;
}
/*
- (BOOL)hasSshKeypairGlobalSupport {
	DASshKeyInfo *info = DASshKeyInfo.globalKeysInfo;
	
	BOOL isPublicKeyExistent = [self.app.fs isFileExistent:info.publicKeyPath];
	BOOL isPrivateKeyExistent = [self.app.fs isFileExistent:info.publicKeyPath];
	
	// TODO: Check passphrase exists for global keys.
	return isPublicKeyExistent && isPrivateKeyExistent;
}*/

- (BOOL)hasSshKeypairSupportForServer:(DAGitServer *)server {
	DASshKeyInfo *info = [self keysForServer:server];

	BOOL isPublicKeyExistent = [self.app.fs isFileExistent:info.publicKeyPath];
	BOOL isPrivateKeyExistent = [self.app.fs isFileExistent:info.publicKeyPath];
	
	return isPublicKeyExistent && isPrivateKeyExistent;
}
/*
- (DASshKeyInfo *)globalKeys {
	return DASshKeyInfo.globalKeysInfo;
}*/

- (DASshKeyInfo *)keysForServer:(DAGitServer *)server {
	DASshKeyInfo *key = self.cachedServerKeys[server.name];
	if (!key) {
		key = [DASshKeyInfo keysInfoForServer:server];
		self.cachedServerKeys[server.name] = key;
	}
	return key;
}

- (void)scanNewKeyArchives {
	NSArray *files = [self.app.fs contentsOfDirectoryAtPath:self.app.documentsPath error:nil];
	for (NSString *fileName in files) {
		NSString *path = [self.app.documentsPath stringByAppendingPathComponent:fileName];
		
		BOOL isFile = [self.app.fs isFileExistent:path];
		if (!isFile || ![path.pathExtension isEqualToString:ZipExtension]) {
			continue;
		}
		
		NSString *name = fileName.stringByDeletingPathExtension;
		
		DAGitServer *server = DAServerManager.manager.namedList[name];
		if (!server) {
			NSString *fmt = NSLocalizedString(@"Found ssh archive '%@' but no Server with the same name exists.", nil);
			
			[self showErrorMessage:[NSString stringWithFormat:fmt, fileName]];
			continue;
		}
		
		[Logger info:@"Found new SSH keys archive for server: %@", name];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self unzipServerArchiveAtPath:path];
		});
	}
}

- (void)unzipServerArchiveAtPath:(NSString *)path {
	NSString *fileName = path.lastPathComponent;
	NSString *serverName = fileName.stringByDeletingPathExtension;
	
	DAGitServer *server = DAServerManager.manager.namedList[serverName];
	if (!server) {
		NSString *fmt = NSLocalizedString(@"Found %@ archive but no server with %@ name exists.", nil);
		[self showErrorMessage:[NSString stringWithFormat:fmt, fileName, serverName]];
		return;
	}
	
	ZipArchive *arch = [ZipArchive.alloc initWithFileManager:self.app.fs];
	
	[arch UnzipOpenFile:path];
	[arch UnzipFileTo:path.stringByDeletingPathExtension overWrite:YES];
	[arch UnzipCloseFile];
	
	if (arch.unzippedFiles.count < 2) {
		[Logger error:@"Failed to unzip keys from path: %@", path];
		
		NSString *fmt = NSLocalizedString(@"Failed to unzip & install SSH keys from archive: %@", nil);
		NSString *message = [NSString stringWithFormat:fmt, fileName];
		[self showErrorMessage:message];
	} else {
		[self requestCredentialsForServer:server];
	}
	
	[self.app.fs removeItemAtPath:path error:nil];
}

- (void)requestCredentialsForServer:(DAGitServer *)server {
	DASshKeyInfo *item = [self keysForServer:server];
	
	NSString *message = NSLocalizedString(@"Passphrase required to install\nnew SSH keys.", nil);
	
	DAAlert *alert = [DAAlert plainTextAlertWithTitle:server.name message:message];
	alert.delegate = item;
	[self.alert enqueueAlert:alert];
}

- (void)showErrorMessage:(NSString *)message {
	DAAlert *alert = [DAAlert errorAlertWithMessage:message];
	[self.alert enqueueAlert:alert];
}

#pragma mark Properties

- (UIApplication *)app {
	return UIApplication.sharedApplication;
}

- (DAAlertQueue *)alert {
	return AlertQueue.queue;
}

@end
