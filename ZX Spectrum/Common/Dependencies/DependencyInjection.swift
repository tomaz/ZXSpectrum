//
//  Created by Tomaz Kragelj on 24/06/16.
//  Copyright © 2016 Gentle Bytes. All rights reserved.
//

import UIKit

extension NSObject {
	
	typealias Handler = (AnyObject, AnyObject) -> Void
	
	/**
	Recursively injects all dependencies from receiver to controller hierarchy starting at the given controller.
	
	You can optionally provide custom handler which is called after handling builtin consumers.
	*/
	func inject(toController controller: UIViewController, handler: Handler? = nil) {
		controller.traverse { object in
			self.inject(toObject: object, handler: handler)
		}
	}
	
	/**
	Recursively injects all dependencies from receiver to view hierarchy starting at the given view.
	
	You can optionally provide custom handler which is called after handling builtin consumers.
	*/
	func inject(toView view: UIView, handler: Handler? = nil) {
		view.traverse { object in
			self.inject(toObject: object, handler: handler)
		}
	}
	
	/**
	Injects dependencies to the given object.
	
	You can optionally provide custom handler which is called after handling builtin consumers.
	*/
	func inject(toObject object: AnyObject, handler: Handler? = nil) {
		if let source = self as? PersistentContainerProvider, let destination = object as? PersistentContainerConsumer {
			destination.configure(persistentContainer: source.providePersistentContainer())
		}
		
		if let source = self as? EmulatorProvider, let destination = object as? EmulatorConsumer {
			destination.configure(emulator: source.provideEmulator())
		}
		
		if object is PopoverPresentationConsumer, let controller = object as? UIViewController {
			controller.modalPresentationStyle = .popover
			controller.popoverPresentationController?.delegate = self
		}

		handler?(self, object)
	}
}

extension NSObject: UIPopoverPresentationControllerDelegate {
	
	public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		// Force popover on any presentation.
		return .none
	}
}

extension UIViewController {
	
	/**
	Traverses controller hierarchy starting at receiver. For each controller (including receiver), the given handler closure is called.
	*/
	func traverse(handler: (UIViewController) -> Void) {
		handler(self)
		for child in childViewControllers {
			child.traverse(handler: handler)
		}
	}
}

extension UIView {
	
	/**
	Traverses view hierarhcy starting at receiver. For each view (including receiver), the given handler closure is called.
	*/
	func traverse(handler: (UIView) -> Void) {
		handler(self)
		for child in subviews {
			child.traverse(handler: handler)
		}
	}
}
