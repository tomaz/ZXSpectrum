//
//  Created by Tomaz Kragelj on 26.02.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import Zip

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

extension Database {
	
	/**
	Deletes the file at the given url as well as all files that share the same name but different extension.
	*/
	@discardableResult
	static func deleteUploadedFiles(at url: URL) -> Bool {
		let manager = FileManager.default
		var failedFiles = [String]()
		
		// Get all files with the same name at the folder in which our file resides.
		let filename = url.deletingPathExtension().lastPathComponent
		let baseURL = url.deletingLastPathComponent()
		
		// If we can't enumerate files for some reason, lot and attempt to only remove the main file itself.
		var files = [String]()
		do {
			files = try manager.contentsOfDirectory(atPath: baseURL.path).filter { $0.hasPrefix(filename) }
		} catch {
			gwarn("Failed enumerating contents of \(baseURL): \(error)")
			files = [ url.lastPathComponent ]
		}
		
		// Delete all files associated with this object.
		gdebug("Deleting \(files.count) associated file(s) at \(baseURL)")
		for file in files {
			let absoluteURL = baseURL.appendingPathComponent(file)
			if manager.fileExists(atPath: absoluteURL.path) {
				do {
					gdebug("- \(file)")
					try manager.removeItem(atPath: absoluteURL.path)
				} catch {
					gerror("Failed deleting \(absoluteURL): \(error)")
					failedFiles.append(absoluteURL.differentSuffix(with: Database.filesURL))
				}
			}
		}
		
		// If the folder becomes empty, delete it too. Note in this case we don't report the error as it would likely only confuse the user.
		if failedFiles.isEmpty {
			do {
				let remainingFiles = try manager.contentsOfDirectory(atPath: baseURL.path).filter { !$0.hasPrefix(".") }
				if remainingFiles.isEmpty {
					gdebug("Deleting now empty folder at \(baseURL)")
					try manager.removeItem(at: baseURL)
				}
			} catch {
				gwarn("Failed checking or deleting folder \(baseURL): \(error)")
			}
		}
		
		// If there were any errors, present them now.
		if !failedFiles.isEmpty {
			UIViewController.current.present(error: NSError.delete(paths: failedFiles))
		}
		
		return failedFiles.isEmpty
	}

	/**
	Moves downloaded file from given temporary URL to upload folder.
	
	If file is zip, it unzips it; if this fails, it'll bail out without further handling. Regardless, it checks for file validity; if it's unsupported file, it will bail out without moving.
	*/
	@discardableResult
	static func moveDownloadedFile(from url: URL, source: URL? = nil) throws -> URL {
		let manager = FileManager.default
		
		// Prepare default values.
		var sourceURL = url
		var filename = source?.lastPathComponent ?? url.lastPathComponent
		let ext = source?.pathExtension ?? url.pathExtension

		// Zip will fail if extension is not zip!
		func rename() throws {
			if ext.lowercased() == "zip" && url.pathExtension.lowercased() != "zip" {
				let originalURL = sourceURL
				sourceURL = sourceURL.deletingLastPathComponent().appendingPathComponent(filename)
				
				if manager.fileExists(atPath: sourceURL.path) {
					gdebug("Removing existing renamed temporary file at \(sourceURL)")
					try manager.removeItem(at: sourceURL)
				}
				
				gdebug("Renaming temporary file from \(originalURL) to \(sourceURL)")
				try manager.moveItem(at: originalURL, to: sourceURL)
			}
		}

		// Unzipping
		func unzip() throws {
			if (ext.lowercased() == "zip") {
				gdebug("Unzipping \(url)")
				do {
					sourceURL = try Zip.quickUnzipFile(sourceURL)
					filename = sourceURL.lastPathComponent
				} catch {
					gwarn("Failed unzipping \(url) \(error)")
					throw NSError.move(description: NSLocalizedString("Failed unzipping file."), error: error)
				}
			}
		}
		
		func move() throws -> URL {
			let destinationURL = filesURL.appendingPathComponent(filename)
			
			if manager.fileExists(atPath: destinationURL.path) {
				gdebug("Removing existing file at \(destinationURL)")
				try manager.removeItem(at: destinationURL)
			}
			
			gdebug("Moving file from \(sourceURL) to \(destinationURL)")
			try manager.moveItem(at: sourceURL, to: destinationURL)
			
			return destinationURL
		}
		
		// Move the file.
		do {
			try createUploadFolder()
			try rename()
			try unzip()
			return try move()
		} catch {
			gwarn("Failed creating upload folder \(error)")
			throw NSError.move(description: NSLocalizedString("Failed moving downloaded file."), error: error)
		}
	}
	
	/**
	Creates upload folder if it doesn't exist yet.
	*/
	@discardableResult
	static func createUploadFolder() throws -> String {
		let result = Database.filesURL.path
		let manager = FileManager.default
		if !manager.fileExists(atPath: result) {
			gverbose("Creating files folder")
			try manager.createDirectory(atPath: result, withIntermediateDirectories: true, attributes: nil)
		}
		return result
	}
}

extension NSManagedObjectContext {
	
	/**
	Imports all new files into the context as well as deletes all obsolete files. Returns true if files were uploaded or deleted, false if there's no change.
	*/
	@discardableResult
	func importUploadedFiles(save: Bool = true) -> Bool {
		gdebug("Importing new uploaded files")
		var result = false

		let manager = FileManager.default
		let baseURL = Database.filesURL
		
		// If files path doesn't exist, ignore.
		if !manager.fileExists(atPath: baseURL.path) {
			gdebug("Files folder doesn't exist, no need to check for new files")
			return result
		}
		
		// Get existing uploaded objects.
		let existingObjectsArray = FileObject.fetch(in: self) { request in
			request.predicate = FileObject.predicate(stock: false)
			request.propertiesToFetch = FileObject.pathProperties
		}
		
		// Prepare dictionary where keys are paths and values are objects themselves.
		var existingObjects = [String: FileObject]()
		for object in existingObjectsArray {
			existingObjects[object.relativeURL.relativePath] = object
		}
		
		// Prepare known file extensions.
		let knownFileExtensions = [ "tzx", "tap", "z80", "szx" ]
		
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
			
			// Ignore unknown file extensions.
			if !knownFileExtensions.contains(absoluteURL.pathExtension) {
				continue
			}
			
			// Ignore existing objects; if user uploaded different file with same name, we'll use the new file next time anyway.
			if existingObjects[file] != nil {
				existingObjects.removeValue(forKey: file)
				continue
			}

			// Create new object.
			gdebug("Detected new file \(file)")
			let relativeURL = URL(fileURLWithPath: file)
			let object = FileObject(context: self)
			object.url = relativeURL
			
			// Indicate change.
			result = true
		}
		
		// Remove all previously existing objects that no longer exist.
		for (_, object) in existingObjects {
			gdebug("Deleting \(object)")
			object.delete()
			result = true
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
