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
	Asks for confirmation for deleting the given snapshot and calls given completion handler when done.
	*/
	static func deleteSnapshot(for object: FileObject, completionHandler: ((NSError?) -> Void)?) {
		let bytes = Database.snapshotSize(for: object)
		let size = Formatter.size(fromBytes: bytes)
		
		let message = NSLocalizedString("This will free \(size.value) \(size.unit) but cannot be undone. Are you sure?")
		let alert = UIAlertController(title: NSLocalizedString("Delete Snapshot?"), message: message, preferredStyle: .alert)
		
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
	
	/**
	Asks for confirmation for deleting all snapshots and calls given completion handler when done.
	*/
	static func deleteAllSnapshots(completionHandler: ((NSError?) -> Void)?) {
		let bytes = Database.totalSnapshotsSize.value
		let size = Formatter.size(fromBytes: bytes)
		
		let message = NSLocalizedString("This will free \(size.value) \(size.unit) but cannot be undone. Are you sure?")
		let alert = UIAlertController(title: NSLocalizedString("Delete All Snapshots?"), message: message, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("Delete"), style: .destructive) { action in
			ginfo("Deleting all snapshots")
			do {
				try Database.deleteAllSnapshots()
				completionHandler?(nil)
			} catch {
				gwarn("Failed deleting all snapshots \(error)")
				completionHandler?(error as NSError)
			}
		})
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel, handler: nil))
		
		UIViewController.current.present(alert, animated: true, completion: nil)
	}
}
