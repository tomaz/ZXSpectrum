//
//  Created by Tomaz Kragelj on 16.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import Bond

/**
Manages list of tapes and other files.
*/
class FilesViewController: UICollectionViewController {
	
	fileprivate var persistentContainer: NSPersistentContainer!
	
	/// Array of files; use `fetch` to update.
	fileprivate lazy var files = MutableObservableArray<FileObject>([])
	
	/// Bond for collection view.
	fileprivate lazy var bond = Bond()
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		files.bind(to: collectionView!, using: bond)
		
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
