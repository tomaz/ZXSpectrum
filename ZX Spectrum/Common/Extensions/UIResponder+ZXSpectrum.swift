//
//  Created by Tomaz Kragelj on 18.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData

extension UIResponder {
	
	/**
	Presents the given error by relaying it to current view controller.
	*/
	func present(error: NSError, completionHandler: ((Bool) -> Void)? = nil) {
		UIViewController.current.present(error: error, completionHandler: completionHandler)
	}
}
