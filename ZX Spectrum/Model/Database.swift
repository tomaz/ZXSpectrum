//
//  Created by Tomaz Kragelj on 26.02.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData

class Database {
	
	/**
	Creates persistent container and sends it to the completion block.
	*/
	func createPersistentContainer(completion: @escaping (NSPersistentContainer) -> Void) {
		gdebug("Setting up persistent container")
		
		let container = NSPersistentContainer(name: "Model")
		container.loadPersistentStores { storeDescription, error in
			if let error = error {
				fatalError("Failed loading store \(error)")
			}
			
			gdebug("Determining initial data status")
			container.performBackgroundTask { context in
				context.undoManager?.disableUndoRegistration()
				
				context.importStockFiles()
				context.importUploadedFiles(save: false)
				
				context.undoManager?.enableUndoRegistration()
				
				try! context.save()
				
				gdebug("Finished setting up presistent container")
				onMain {
					completion(container)
				}
			}
		}
	}
	
	/**
	URL for files base folder.
	*/
	static let filesURL: URL = {
		return documentsURL.appendingPathComponent("Files")
	}()
	
	/**
	URL for documents base folder.
	*/
	static let documentsURL: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}()
}

// MARK: - Uploaded files handling

extension NSManagedObjectContext {
	
	/**
	Imports all new files into the context. Returns number of new files.
	*/
	@discardableResult
	func importUploadedFiles(save: Bool = true) -> Int {
		gdebug("Importing new uploaded files")
		var result = 0

		let manager = FileManager.default
		let baseURL = Database.filesURL
		
		// If files path doesn't exist, ignore.
		if !manager.fileExists(atPath: baseURL.path) {
			gdebug("Files folder doesn't exist, no need to check for new files")
			return result
		}
		
		// Get existing file objects.
		let existingObjectsArray = FileObject.fetch(in: self)
		
		// Prepare dictionary where keys are paths and values are objects themselves.
		var existingObjects = [String: FileObject]()
		for object in existingObjectsArray {
			existingObjects[object.relativeURL.relativePath] = object
		}
		
		// Perform search for all files.
		let files = try! manager.subpathsOfDirectory(atPath: baseURL.path)
		for file in files {
			let absoluteURL = baseURL.appendingPathComponent(file)

			// Ignore hidden files. This is mostly used on Simulator.
			if absoluteURL.lastPathComponent.hasPrefix(".") {
				continue
			}

			// Ignore folders.
			if manager.isDirectory(at: absoluteURL.path) {
				continue
			}

			// Ignore existing objects; if user uploaded different file with same name, we'll use the new file next time anyway.
			if existingObjects[file] != nil {
				continue
			}

			// Create new object.
			gdebug("Detected new file \(file)")
			let relativeURL = URL(fileURLWithPath: file)
			let object = FileObject(context: self)
			object.url = relativeURL
			
			// Increase number of imported objects.
			result += 1
		}
		
		if save {
			gdebug("Saving")
			try! self.save()
		}
		
		return result
	}
}

// MARK: - Stock files handling

extension NSManagedObjectContext {

	/**
	Imports stock files into database.
	*/
	fileprivate func importStockFiles() {
		gdebug("Importing stock files")

		// If we already have files in database, ignore.
		let count = FileObject.count(in: self)
		if count > 0 {
			gdebug("Found \(count) existing files in database, no need to check for stock files")
			return
		}
		
		let bundle = Bundle.main
		let files = bundle.paths(forResourcesOfType: "tzx", inDirectory: nil)
		gdebug("Found \(files.count) stock files")
		
		for file in files {
			let object = FileObject(context: self)
			let absoluteURL = URL(fileURLWithPath: file)
			object.isStock = true
			object.path = ""
			object.filename = absoluteURL.lastPathComponent
		}
	}
}
