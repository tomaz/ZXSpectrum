//
//  Created by Tomaz Kragelj on 16.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

// MARK: - Tap on background handling

extension UIViewController {
	
	/**
	Setups tap on background interaction.
	
	This should typically be called in `prepare(for:sender:)` for modal segue you want to dismiss by tapping on background view. You can optionally supply a handler that's called just prior than dismissing. You must call `teardownTapOnBackgroundInteraction()` in `viewWillAppear(_:)` to remove handler.
	
	If interaction is already setup, nothing happens and exisiting interaction is used.
	*/
	func setupTapOnBackgroundInteraction(handler: (() -> Void)? = nil) {
		gdebug("Setting up background interaction")
		let recognizer = UITapGestureRecognizer { recognizer in
			guard recognizer.state == .ended else {
				return
			}
			
			guard let view = self.presentedViewController?.view else {
				return
			}
			
			let pointInPresentedView = recognizer.location(in: view)
			if view.point(inside: pointInPresentedView, with: nil) {
				return
			}
			
			handler?()
			
			self.dismiss(animated: true, completion: nil)
		}
		
		_tapOnBackgroundDelegate = TapOnBackgroundRecognizerDelegate(recognizer: recognizer, view: view)
	}
	
	/**
	Tears down tap on background interaction.
	
	If interaction is not setup, nothing happens.
	*/
	func teardownTapOnBackgroundInteraction() {
		if let delegate = _tapOnBackgroundDelegate {
			gdebug("Tearing down background interaction")
			view.window?.removeGestureRecognizer(delegate.recognizer)
		}
	}
	
	private var _tapOnBackgroundDelegate: TapOnBackgroundRecognizerDelegate? {
		get { return objc_getAssociatedObject(self, &UIViewController.AssociatedKeys.TapOnBackgroundDelegateKey) as? TapOnBackgroundRecognizerDelegate }
		set { objc_setAssociatedObject(self, &UIViewController.AssociatedKeys.TapOnBackgroundDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
	private struct AssociatedKeys {
		static var TapOnBackgroundDelegateKey = "TapOnBackgroundDelegateKey"
	}
}

/**
Handles tap ob background recognizer delegate and parameterization.
*/
private class TapOnBackgroundRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
	
	let recognizer: UITapGestureRecognizer
	
	init(recognizer: UITapGestureRecognizer, view: UIView) {
		self.recognizer = recognizer

		super.init()
		
		recognizer.numberOfTapsRequired = 1
		recognizer.cancelsTouchesInView = false // otherwise taps on modal view will be prevented
		recognizer.delegate = self // otherwise recognizer won't be handled simultaneously with other recognizers
		
		view.window?.addGestureRecognizer(recognizer)
	}
	
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
