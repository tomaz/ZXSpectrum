//
//  Created by Tomaz Kragelj on 13.09.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Provides commonly used alerts.
*/
class Alert {
	
	/**
	Asks for confirmation for deleting the given snapshot and calls given completion handler if user confirms and file was deleted.
	*/
	static func deleteSnapshot(for object: FileObject, completionHandler: ((NSError?) -> Void)?) {
		let bytes = Database.snapshotSize(for: object)
		let size = Formatter.size(fromBytes: bytes)
		
		let message = NSLocalizedString("This will free \(size.value) \(size.unit) but cannot be undone.\nAre you sure?")
		let alert = UIAlertController(title: NSLocalizedString("Delete Snapshop?"), message: message, preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("Delete"), style: .destructive) { action in
			ginfo("Deleting snapshot")
			do {
				try Database.deleteSnapshot(for: object)
				completionHandler?(nil)
			} catch {
				gwarn("Failed deleting snapshot \(error)")
				completionHandler?(error as NSError)
			}
		})
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel, handler: nil))
		
		UIViewController.current.present(alert, animated: true, completion: nil)
	}
}
