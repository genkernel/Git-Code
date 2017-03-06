//
//  Environment.swift
//  xlib
//
//  Created by Altukhov Anton on 10/7/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

import Foundation

fileprivate let env = Environment()

@objc
open class Environment: NSObject {
	#if DEBUG
	public let isDebug = true
	public let isRelease = false
	#else
	open let isDebug = false
	open let isRelease = true
	#endif
	
	class open func current() -> Environment {
		return env
	}
	
	override init() {
		if isRelease {
			print("\nRelease build. Set '-D DEBUG' in 'Other Swift Flags' to enable debug mode in swift.\n")
		}
	}
}
