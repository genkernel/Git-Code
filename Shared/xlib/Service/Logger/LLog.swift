//
//  File.swift
//  xlib
//
//  Created by Altukhov Anton on 10/7/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

import Foundation

public extension LLog {
	class public func info( _ format: @autoclosure () -> String, _ args: CVarArg...) {
		LLog.info(format(), args:getVaList(args))
	}
	
	class public func warn( _ format: @autoclosure () -> String, _ args: CVarArg...) {
		LLog.info(format(), args:getVaList(args))
	}
	
	class public func error( _ format: @autoclosure () -> String, _ args: CVarArg...) {
		LLog.info(format(), args:getVaList(args))
	}
}
