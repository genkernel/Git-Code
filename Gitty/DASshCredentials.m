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
@end

@implementation DASshCredentials
@dynamic app;

+ (instancetype)manager {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = self.new;
	});
	return instance;
}

- (BOOL)hasSshKeypairGlobalSupport {
	BOOL isPublicKeyExistent = [self.app.fs isFileExistent:DASshKeyInfo.globalKeysInfo.publicKeyPath];
	BOOL isPrivateKeyExistent = [self.app.fs isFileExistent:DASshKeyInfo.globalKeysInfo.publicKeyPath];
	
	// TODO: Check passphrase eixsts for global keys.
	return isPublicKeyExistent && isPrivateKeyExistent;
}

- (BOOL)hasSshKeypairSupportForServer:(DAGitServer *)server {
	return NO;
}

- (DASshKeyInfo *)globalKeys {
	return DASshKeyInfo.globalKeysInfo;
}

- (DASshKeyInfo *)keysForServer:(DAGitServer *)server {
	// TODO: impl keysForServer:
	return self.globalKeys;
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
			[Logger error:@"Found archive '%@' but no Server with the same name exists.", fileName];
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
	
	if (arch.unzippedFiles.count < 2) {
		[Logger error:@"Failed to unzip keys from path: %@", path];
	}
	
	[self.app.fs removeItemAtPath:path error:nil];
}

#pragma mark Properties

- (UIApplication *)app {
	return UIApplication.sharedApplication;
}

@end
