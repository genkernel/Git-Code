//
//  Cryptor.m
//  xlib
//
//  Created by kernel on 6/06/13.
//  Copyright (c) 2013 ReImpl. All rights reserved.
//

#import "Cryptor.h"
#import <CommonCrypto/CommonDigest.h>

@interface NSString (Cryptor)
- (NSString *)md5;
- (NSString *)sha512;
@end

@implementation Cryptor

+ (NSString *)md5ForString:(NSString *)str {
	if (!str) {
		return nil;
	}
	
	static NSMutableDictionary *cache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = NSMutableDictionary.new;
	});
	
	NSString *hash = cache[str];
	if (hash) {
		return hash;
	}
	
	hash = str.md5;
	cache[str] = hash;
	
	return hash;
}

+ (NSString *)sha512ForString:(NSString *)str {
	if (!str) {
		return nil;
	}
	
	static NSMutableDictionary *cache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = NSMutableDictionary.new;
	});
	
	NSString *hash = cache[str];
	if (hash) {
		return hash;
	}
	
	hash = str.sha512;
	cache[str] = hash;
	
	return hash;
}

@end

@implementation NSString (Cryptor)

- (NSString *)md5
{
	// Create pointer to the string as UTF8
	const char *ptr = [self UTF8String];
	
	// Create byte array of unsigned chars
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
	
	// Create 16 byte MD5 hash value, store in buffer
	CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
	
	// Convert MD5 value in the buffer to NSString of hex values
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x",md5Buffer[i]];
	}
	
	return output;
}

- (NSString *)sha512
{
	CC_SHA512_CTX context;
	unsigned char digest[CC_SHA512_DIGEST_LENGTH];
	
	CC_SHA512_Init(&context);
	memset(digest, 0, sizeof(digest));
	
	CC_SHA512_Update(&context, self.UTF8String, (CC_LONG)self.length);
	
	CC_SHA512_Final(digest, &context);
	
	NSMutableString *str = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH];
	for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
		[str appendFormat:@"%02x", digest[i]];
	}
	
	return [NSString stringWithString:str];
}

@end
