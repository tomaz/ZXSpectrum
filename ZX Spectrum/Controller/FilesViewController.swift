//
//  Created by Tomaz Kragelj on 16.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import GCDWebServers
import Bond

/**
Manages list of tapes and other files.
*/
final class FilesViewController: UICollectionViewController {
	
	@IBOutlet fileprivate weak var uploadBarButtonItem: UIBarButtonItem!
	
	// MARK: - Dependencies
	
	/// Persistent container.
	fileprivate var persistentContainer: NSPersistentContainer!
	
	// MARK: - Data
	
	/// Array of files; use `fetch` to update.
	fileprivate lazy var files = MutableObservableArray<FileObject>([])
	
	// MARK: - Helpers
	
	fileprivate lazy var bond = Bond()
	fileprivate lazy var sizer = Sizer()
	fileprivate lazy var server = WebServer()
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		gdebug("Binding data")
		sizer.bind(to: collectionView!)
		files.bind(to: collectionView!, using: bond)
		
		gdebug("Setting up view")
		setupUploadButtonTapSignal()
		
		fetch(animated: false)
	}
}

// MARK: - Dependencies

extension FilesViewController: PersistentContainerConsumer {
	
	func configure(persistentContainer: NSPersistentContainer) {
		gdebug("Configuring with \(persistentContainer)")
		self.persistentContainer = persistentContainer
	}
}

// MARK: - Data

extension FilesViewController {
	
	/**
	Fetches data and updates `files` with results.
	*/
	fileprivate func fetch(animated: Bool = true) {
		gdebug("Fetching files")
		
		let context = persistentContainer.viewContext
			
		context.perform {
			let files = FileObject.fetch(in: context)
			
			gdebug("Updating with \(files.count) files")
			self.files.replace(with: files, performDiff: animated)
		}
	}
}

// MARK: - Signals handling

extension FilesViewController {
	
	fileprivate func setupUploadButtonTapSignal() {
		uploadBarButtonItem.reactive.tap.observeNext {
			ginfo("Starting upload")
			
			// Start server.
			do {
				try self.server.start()
			} catch {
				gerror("Failed starting server: \(error)")
				self.present(error: error as NSError)
				return
			}
			
			// Present alert for user.
			let url = self.server.serverURL!
			let title = NSLocalizedString("Upload Server Active!")
			let message = NSLocalizedString("You can upload files by visiting\n\n\(url.absoluteString)\n\nin web browser on your computer. When done tap stop button below.")
			let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
			
			alert.addAction(UIAlertAction(title: NSLocalizedString("Stop"), style: .default) { action in
				gdebug("Stopping upload server")
				self.server.stop()
				
				if self.persistentContainer.viewContext.importUploadedFiles() > 0 {
					self.fetch()
				}
			})
			
			self.present(alert, animated: true, completion: nil)
		}.dispose(in: reactive.bag)
	}
}
