//
//  UIDevice+Helper.m
//  MakeMyPlan
//
//  Created by kernel on 17/02/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "UIDevice+Helper.h"
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

@implementation UIDevice (Helper)

- (BOOL)isDevice {
	return !self.isSimulator;
}

- (BOOL)isSimulator {
	static BOOL isSimulator;
	
#if TARGET_IPHONE_SIMULATOR
	isSimulator = YES;
#else
	isSimulator = NO;
#endif
	
	return isSimulator;
}

- (CGFloat)systemVersionNumber {
	static CGFloat version;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		version = UIDevice.currentDevice.systemVersion.floatValue;
	});
	
	return version;
}

- (BOOL)isIos6Family
{
	return self.systemVersionNumber >= 6.0 && self.systemVersionNumber < 7.0;
}

- (BOOL)isIos7Family
{
	return self.systemVersionNumber >= 7.0 && self.systemVersionNumber < 8.0;
}

- (BOOL)isIos8Family
{
	return self.systemVersionNumber >= 8.0 && self.systemVersionNumber < 9.0;
}

- (BOOL)isIos7FamilyOrGreater
{
	return self.systemVersionNumber >= 7.0;
}

- (BOOL)isIos8FamilyOrGreater
{
	return self.systemVersionNumber >= 8.0;
}

- (NSString *)macAddress
{
	static NSString *macAddressString = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		int                 mgmtInfoBase[6];
		char                *msgBuffer = NULL;
		size_t              length;
		unsigned char       macAddress[6];
		struct if_msghdr    *interfaceMsgStruct;
		struct sockaddr_dl  *socketStruct;
		NSString            *errorFlag = nil;
		
		// Setup the management Information Base (mib)
		mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
		mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
		mgmtInfoBase[2] = 0;
		mgmtInfoBase[3] = AF_LINK;        // Request link layer information
		mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
		
		// With all configured interfaces requested, get handle index
		if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
			errorFlag = @"if_nametoindex failure";
		else
		{
			// Get the size of the data available (store in len)
			if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
				errorFlag = @"sysctl mgmtInfoBase failure";
			else
			{
				// Alloc memory based on above call
				if ((msgBuffer = malloc(length)) == NULL)
					errorFlag = @"buffer allocation failure";
				else
				{
					// Get system information, store in buffer
					if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
						errorFlag = @"sysctl msgBuffer failure";
				}
			}
		}
		
		// Befor going any further...
		if (errorFlag != nil)
		{
			[LLog error:@"Failed to determine MAC address. Error: %@", errorFlag];
			if (msgBuffer) {
				free(msgBuffer);
			}
			return;
		}
		
		// Map msgbuffer to interface message structure
		interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
		// Map to link-level socket structure
		socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
		// Copy link layer address data in socket structure to an array
		if (socketStruct == NULL) {
			[LLog error:@"ERR. Failed to determine MAC address. Error: %@", errorFlag];
			if (msgBuffer) {
				free(msgBuffer);
			}
			return;
		}
		
		memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
		// Read from char array into a string object, into traditional Mac address format
		macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
							macAddress[0], macAddress[1], macAddress[2],
							macAddress[3], macAddress[4], macAddress[5]];
		
		free(msgBuffer);
	});
	
    return macAddressString;
}

@end
