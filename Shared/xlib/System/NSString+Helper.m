//
//  NSString+Helper.m
//  Gitty
//
//  Created by kernel on 31/05/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (NSString *)concat:(NSString *)str {
	if (str) {
		return [self stringByAppendingString:str];
	}
	return self.copy;
}

- (NSString *)concatPath:(NSString *)path {
	if (path) {
		return [self stringByAppendingPathComponent:path];
	}
	return self.copy;
}

- (NSString *)concatExt:(NSString *)extention {
	if (extention) {
		return [self stringByAppendingPathExtension:extention];
	}
	return self.copy;
}

- (NSString *)encodedString {
//	;$()',
//	'();$,%[]
	
	NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"];
	return [self stringByAddingPercentEncodingWithAllowedCharacters:set];
	
//	return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

- (NSString *)decodedString {
//	self stringByRemov
	
	return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)self, CFSTR("")));
	
//	return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));
}

- (BOOL)isValidIPAddress {
	/*
	 const char *utf8 = [self UTF8String];
	 
	 struct in_addr dst;
	 int success = inet_pton(AF_INET, utf8, &dst);
	 
	 if (success != 1) {
		struct in6_addr dst6;
		success = inet_pton(AF_INET6, utf8, &dst6);
	 }
	 
	 return success == 1;
	 */
	
	int ipQuads[4];
	const char *ipAddress = [self cStringUsingEncoding:NSUTF8StringEncoding];
	
	sscanf(ipAddress, "%d.%d.%d.%d", &ipQuads[0], &ipQuads[1], &ipQuads[2], &ipQuads[3]);
	
	int quad = 0;
	for (; quad < 4; quad++) {
		if ((ipQuads[quad] < 0) || (ipQuads[quad] > 255)) {
			return NO;
		}
	}
	
	return quad == 4;
}

@end
