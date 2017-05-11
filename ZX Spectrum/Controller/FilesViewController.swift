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
final class FilesViewController: UITableViewController {
	
	@IBOutlet fileprivate weak var uploadBarButtonItem: UIBarButtonItem!
	
	// MARK: - Dependencies
	
	fileprivate var persistentContainer: NSPersistentContainer!
	fileprivate var emulator: Emulator!
	
	// MARK: - Data
	
	/// Array of files; use `fetch` to update.
	fileprivate lazy var files = MutableObservable2DArray<String, FileObject>([])
	
	// MARK: - Helpers
	
	fileprivate lazy var bond = Bond()
	fileprivate lazy var server = WebServer()
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		
		gdebug("Binding data")
		bond.initialize(tableView: tableView)
		bond.didRequestInsert = insert(object:)
		bond.didRequestDelete = delete(object:)
		files.bind(to: tableView, using: bond)
		
		gdebug("Setting up view")
		setupUploadButtonTapSignal()
		setupTableSelectionSignal()
		
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

extension FilesViewController: EmulatorConsumer {
	
	func configure(emulator: Emulator) {
		gdebug("Configuring with \(emulator)")
		self.emulator = emulator
	}
}

// MARK: - Data

extension FilesViewController {
	
	/**
	Fetches data and updates `files` with results.
	*/
	fileprivate func fetch(animated: Bool = true) {
		gdebug("Fetching files")
		let sections = bond.fetch(in: persistentContainer.viewContext)

		gdebug("Updating with \(sections.count) sections")
		files.replace(with: sections, performDiff: animated)
	}
	
	/**
	Inserts the given object for playback.
	*/
	fileprivate func insert(object: FileObject) {
		let name = object.url.path.toInt8Array

		emulator.openFile(name)
		
		after(0.5) {
			self.performSegue(withIdentifier: "UnwindToEmulatorScene", sender: self)
			Defaults.currentObjectID.value = object.objectID
		}
	}
	
	/**
	Deletes the given object.
	*/
	fileprivate func delete(object: FileObject) {
		if let context = object.managedObjectContext {
			let name = object.displayName
			
			let title = NSLocalizedString("Delete \(name)?")
			
			let message = object.isStock ?
				NSLocalizedString("\(name) comes bundled with application! The only way to add it back after deleting is to delete all other files and restart application.") :
				NSLocalizedString("You can upload files any time by tapping \"Upload\" button in the top right.")
			
			let deleteTitle = object.isStock ? NSLocalizedString("Delete Anyway") : NSLocalizedString("Delete")
			
			let confirmation = UIAlertController(title: title, message: message, preferredStyle: .alert)
			
			confirmation.addAction(UIAlertAction(title: deleteTitle, style: .destructive, handler: { action in
				if object.deleteObjectAndAssociatedFiles() {
					context.savePresentingError()
					self.fetch(animated: true)
				}
			}))
			
			confirmation.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel, handler: nil))
			
			present(confirmation, animated: true, completion: nil)
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
				
				if self.persistentContainer.viewContext.importUploadedFiles() {
					self.fetch()
				}
			})
			
			self.present(alert, animated: true, completion: nil)
		}.dispose(in: reactive.bag)
	}
	
	fileprivate func setupTableSelectionSignal() {
		tableView.reactive.deselectedRow.bind(to: self) { me, indexPath in
			gverbose("Deselected cell at \(indexPath)")
			me.bond.selectCell(at: indexPath, select: false)
		}
		
		tableView.reactive.selectedRow.bind(to: self) { me, indexPath in
			gverbose("Selected cell at \(indexPath)")
			me.bond.selectCell(at: indexPath)
		}
	}
}
