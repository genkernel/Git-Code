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

- (BOOL)hasSshKeypairGlobalSupport {
	DASshKeyInfo *info = DASshKeyInfo.globalKeysInfo;
	
	BOOL isPublicKeyExistent = [self.app.fs isFileExistent:info.publicKeyPath];
	BOOL isPrivateKeyExistent = [self.app.fs isFileExistent:info.publicKeyPath];
	
	// TODO: Check passphrase exists for global keys.
	return isPublicKeyExistent && isPrivateKeyExistent;
}

- (BOOL)hasSshKeypairSupportForServer:(DAGitServer *)server {
	DASshKeyInfo *info = [DASshKeyInfo keysInfoForServer:server];

	BOOL isPublicKeyExistent = [self.app.fs isFileExistent:info.publicKeyPath];
	BOOL isPrivateKeyExistent = [self.app.fs isFileExistent:info.publicKeyPath];
	
	// TODO: Check passphrase exists for global keys.
	return isPublicKeyExistent && isPrivateKeyExistent;
}

- (DASshKeyInfo *)globalKeys {
	return DASshKeyInfo.globalKeysInfo;
}

- (DASshKeyInfo *)keysForServer:(DAGitServer *)server {
	return [DASshKeyInfo keysInfoForServer:server];
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
	ZipArchive *arch = [ZipArchive.alloc initWithFileManager:self.app.fs];
	
	[arch UnzipOpenFile:path];
	[arch UnzipFileTo:path.stringByDeletingPathExtension overWrite:YES];
	[arch UnzipCloseFile];
	
	if (YES || arch.unzippedFiles.count < 2) {
		[Logger error:@"Failed to unzip keys from path: %@", path];
		
		NSString *fmt = NSLocalizedString(@"Failed to unzip & install SSH keys from archive: %@", nil);
		NSString *message = [NSString stringWithFormat:fmt, path.lastPathComponent];
		[self showErrorMessage:message];
	}
	
	[self.app.fs removeItemAtPath:path error:nil];
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
	return DAAlertQueue.manager;
}

@end
