//
//  UI-Constants.swift
//  xlib
//
//  Created by Altukhov Anton on 10/10/14.
//  Copyright (c) 2014 ReImpl. All rights reserved.
//

import Foundation

@objc
open class AnimationDuration: NSObject {
	class open var Lightning: TimeInterval {get {return 0.200}}
	class open var Standard: TimeInterval {get {return 0.350}}
	class open var Smooth: TimeInterval {get {return 0.650}}
	class open var Extra: TimeInterval {get {return 0.950}}
}

