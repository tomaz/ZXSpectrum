//
//  Created by Tomaz Kragelj on 24/06/16.
//  Copyright © 2016 Gentle Bytes. All rights reserved.
//

import UIKit

extension NSObject {
	
	/**
	Recursively injects all dependencies from receiver to controller hierarchy starting at the given controller.
	*/
	func inject(toController controller: UIViewController) {
		controller.traverse { object in
			self.inject(toObject: object)
		}
	}
	
	/**
	Injects dependencies to the given object.
	*/
	func inject(toObject object: AnyObject) {
		if let source = self as? PersistentContainerProvider, let destination = object as? PersistentContainerConsumer {
			destination.configure(persistentContainer: source.providePersistentContainer())
		}
		
		if let source = self as? EmulatorProvider, let destination = object as? EmulatorConsumer {
			destination.configure(emulator: source.provideEmulator())
		}
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
