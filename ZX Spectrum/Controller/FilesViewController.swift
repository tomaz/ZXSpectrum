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
	
	fileprivate var reloadOnAppearance = false
	
	// MARK: - Helpers
	
	fileprivate lazy var bond = Bond()
	fileprivate lazy var server = WebServer()
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		
		refreshControl = FilesSettingsView()
		
		gdebug("Binding data")
		bond.initialize(tableView: tableView)
		bond.didRequestInsert = insert(object:info:)
		bond.didRequestDelete = delete(object:)
		files.bind(to: tableView, using: bond)
		
		gdebug("Setting up view")
		setupUploadButtonTapSignal()
		setupTableSelectionSignal()
		setupFileSortOptionSignal()
		
		fetch(animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		gdebug("Appearing")
		
		super.viewWillAppear(animated)
		
		if reloadOnAppearance {
			if self.persistentContainer.viewContext.importUploadedFiles() {
				self.fetch()
			}
			reloadOnAppearance = false
		}
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
	fileprivate func insert(object: FileObject, info: SpectrumFileInfo?) {
		let name = object.url.path.toInt8Array
		
		// Update last usage date for the object.
		object.used = Date()
		try? object.managedObjectContext?.save()

		// Open the file in emulator.
		emulator.openFile(name)
		
		// Wait a little bit then close files controller. This delay is needed so that emulator properly updates, at least it was unreliable without it during initial implementation - something to check in the future...
		after(0.2) {
			self.performSegue(withIdentifier: "UnwindToEmulatorScene", sender: self)
			Defaults.currentFileInfo.value = info
			Defaults.currentFile.value = object
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

// MARK: - Helper functions

extension FilesViewController {
	
	fileprivate func uploadFromComputer(action: UIAlertAction) {
		ginfo("Starting upload")
		
		// Start server.
		do {
			try server.start()
		} catch {
			gerror("Failed starting server: \(error)")
			present(error: error as NSError)
			return
		}
		
		// Present alert for user.
		let url = server.serverURL!
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
		
		present(alert, animated: true, completion: nil)
	}
	
	fileprivate func downloadFromInternet(action: UIAlertAction) {
		ginfo("Presenting donwload file")
		
		guard let controller = storyboard?.instantiateViewController(withIdentifier: "DownloadFileScene") as? DownloadFileViewController else {
			fatalError("Download file controller not found!")
		}
		
		inject(toController: controller) { me, destination in
			if let downloadController = destination as? DownloadFileViewController {
				downloadController.configure(fileChangeHandler: {
					// Whenever child indicates changes to files, we should reload on next appearance.
					self.reloadOnAppearance = true
				})
			}
		}
		
		navigationController?.pushViewController(controller, animated: true)
	}
}

// MARK: - Signals handling

extension FilesViewController {
	
	fileprivate func setupUploadButtonTapSignal() {
		uploadBarButtonItem.reactive.tap.bind(to: self) { me, _ in
			ginfo("Showing actions")
			
			let title = NSLocalizedString("Actions")
			let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
			
			alert.addAction(UIAlertAction(title: NSLocalizedString("Upload from computer"), style: .default, handler: me.uploadFromComputer(action:)))
			alert.addAction(UIAlertAction(title: NSLocalizedString("Download from internet"), style: .default, handler: me.downloadFromInternet(action:)))
			alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel, handler: nil))
			
			me.present(alert, animated: true, completion: nil)
		}
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
	
	fileprivate func setupFileSortOptionSignal() {
		UserDefaults.standard.reactive.filesSortOptionSignal.bind(to: self) { me, value in
			gverbose("File sorting changed to \(value)")
			me.fetch()
		}
	}
}
