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
	
	/// Updates user tapes into current context. Returns number of imported tapes.
	@discardableResult
	func importUploadedFiles(save: Bool = true) -> Int {
		gdebug("Importing new uploaded files")
//		let manager = FileManager.default
//		
//		// If uploads folder doesn't exist, ignore.
//		if !manager.fileExists(atPath: Database.filesURL.path) {
//			gdebug("Files folder doesn't exist, no need to check for new files")
//			return 0
//		}
//		
//		// Establish path to search in and perform search for all files.
//		let files = try! manager.subpathsOfDirectory(atPath: Database.filesURL.path)
//		gdebug("Found \(files.count) paths")
//		
//		// Add all newly found items.
//		var group: GroupInfo? = nil
//		var result = 0
//		for file in files {
//			if file.pathExtension != "tzx" {
//				continue
//			}
//			
//			gdebug("Found \(file)")
//			let url = Database.filesURL.appendingPathComponent(file)
//			let destinationURL = Database.tapesURL.appendingPathComponent(file.lastPathComponent) // Don't create subfolders on destination
//			
//			if manager.fileExists(atPath: destinationURL.path) {
//				gdebug("File already exists, deleting existing")
//				do {
//					try manager.removeItem(at: destinationURL)
//				} catch {
//					gwarn("Failed removing \(destinationURL): \(error)")
//					continue
//				}
//			}
//			
//			do {
//				try manager.moveItem(at: url, to: destinationURL)
//			} catch {
//				gwarn("Failed moving \(file) from uploads: \(error)")
//				continue
//			}
//			
//			// Create user group if not available.
//			if group == nil {
//				group = GroupInfo.user(in: self)
//			}
//			
//			// Create tape.
//			let tape = TapeInfo(context: self)
//			tape.path = destinationURL.lastPathComponent
//			tape.group = group!
//			
//			// Increase number of imported files.
//			result += 1
//		}
//		
//		if save {
//			gdebug("Saving")
//			try! self.save()
//		}
//		
//		return result
		return 0
	}
}

// MARK: - Stock files handling

extension NSManagedObjectContext {

	/**
	Imports stock files into database.
	*/
	fileprivate func importStockFiles() {
		gdebug("Importing stock files")

		// If we already have stock object(s) in database, ignore.
		let count = FileObject.count(in: self) { request in
			request.predicate = FileObject.stockPredicate
		}
		
		guard count == 0 else {
			gdebug("Found \(count) existing stock files in database")
			return
		}
		
		let bundle = Bundle.main
		let files = bundle.paths(forResourcesOfType: "tzx", inDirectory: nil)
		gdebug("Found \(files.count) stock files")
		
		for file in files {
			let object = FileObject(context: self)
			object.url = URL(fileURLWithPath: file)
			object.isStock = true
		}
	}
}
