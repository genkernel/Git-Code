//
//  TransparentView.swift
//  xlib
//
//  Created by Altukhov Anton on 8/16/15.
//  Copyright © 2015 ReImpl. All rights reserved.
//

import UIKit

@objc
open class TransparentView: UIView {
	weak var blurView: UIView?
	weak var contentView: UIView?
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	open override func addSubview(_ view: UIView) {
		self.prepareBlurViewIfNeeded()
		
		if self.blurView != nil && self.blurView != view {
			self.contentView!.addSubview(view)
		} else {
			super.addSubview(view)
		}
	}
	
	func prepareBlurViewIfNeeded() {
		if self.contentView == nil {
			let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
			
			self.blurView = blurView
			self.contentView = blurView.contentView;
			
			self.addSubview(blurView)
			blurView.pinToSuperviewEdgesNative()
		}
	}
}
