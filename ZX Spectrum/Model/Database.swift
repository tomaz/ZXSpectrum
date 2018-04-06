//
//  Created by Tomaz Kragelj on 26.02.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import ReactiveKit
import Zip

class Database {
	
	/**
	URL for files base folder.
	*/
	static let filesURL: URL = {
		return documentsURL.appendingPathComponent("Files")
	}()
	
	/**
	URL for snapshots base folder..
	*/
	static let snapshotsURL: URL = {
		return documentsURL.appendingPathComponent("Snapshots")
	}()
	
	/**
	URL for documents base folder.
	*/
	static let documentsURL: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}()
	
	/**
	All recognized file extensions.
	*/
	static let allowedFileExtensions: [String] = {
		return ["tzx", "tap"]
	}()
	
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
		
		Database.updateSnapshotsSize()
	}
}

// MARK: - Snapshots handling

extension Database {
	
	/**
	Total snapshots size in bytes.
	
	Any manipulation with snapshots will automatically update this value and post events.
	*/
	static let totalSnapshotsSize = Property(0)
	
	/**
	Opens the snapshot for the given object and updates `totalSnapshotSize`.
	*/
	@discardableResult
	static func openSnapshot(for object: FileObject) -> Bool {
		let url = snapshotURL(for: object)
		
		gverbose("Loading snapshot for \(object)")
		
		// No need to load anything if snapshot doesn't exist.
		if !FileManager.default.fileExists(atPath: url.path) {
			gdebug("Snapshot doesn't exist")
			return false
		}
		
		gdebug("Reading snapshot")
		if snapshot_read(url.path.cString(using: .ascii)) != 0 {
			return false
		}
		
		display_refresh_all()
		return true
	}
	
	/**
	Saves snapshot for the given object and updates `totalSnapshotSize`.
	*/
	static func saveSnapshot(for object: FileObject) throws {
		let url = snapshotURL(for: object)
		let manager = FileManager.default
		
		gverbose("Saving snaphost for \(object)")
		
		if manager.fileExists(atPath: url.path) {
			try manager.removeItem(at: url)
		}
		
		try manager.createDirectory(at: snapshotsURL, withIntermediateDirectories: true, attributes: nil)
		
		snapshot_write(url.path.cString(using: .ascii))

		updateSnapshotsSize()
	}
	
	/**
	Deletes snapshot for the given object, if it exists and updates `totalSnapshotSize`.
	*/
	static func deleteSnapshot(for object: FileObject) throws {
		let url = snapshotURL(for: object)
		let manager = FileManager.default
		
		if !manager.fileExists(atPath: url.path) {
			return
		}
		
		try manager.removeItem(at: url)
		
		updateSnapshotsSize()
	}
	
	/**
	Deletes all snapshots and updates `totalSnapshotSize`.
	*/
	static func deleteAllSnapshots() throws {
		let manager = FileManager.default
		let url = snapshotsURL

		gverbose("Removing snapshots at \(url)")

		if !manager.fileExists(atPath: url.path) {
			gdebug("Snapshots path not present")
			return
		}
		
		try manager.removeItem(at: url)
		
		updateSnapshotsSize()
	}
	
	/**
	Determines the size of the snapshot.
	
	Returns 0 if snapshot is not present.
	*/
	static func snapshotSize(for object: FileObject) -> Int {
		let url = snapshotURL(for: object)
		let manager = FileManager.default
		
		if !manager.fileExists(atPath: url.path) {
			return 0
		}
		
		do {
			let attributes = try manager.attributesOfItem(atPath: url.path)
			if let size = attributes[FileAttributeKey.size] as? Int {
				return size
			}
		} catch {
		}
		
		return 0
	}
	
	private static func snapshotURL(for object: FileObject) -> URL {
		// Snapshots are saved as flat list of files within snapshots folder.
		let filename = object.url.deletingPathExtension().lastPathComponent
		return snapshotsURL.appendingPathComponent(filename).appendingPathExtension("szx")
	}

	fileprivate static func updateSnapshotsSize() {
		if let item = snapshotCalculationWorkItem {
			gdebug("Cancelling ongoing calculation")
			item.cancel()
		}
		
		let item = DispatchWorkItem {
			let manager = FileManager.default
			var result = 0
			
			defer {
				gverbose("Total snapshot size is \(result)")
				DispatchQueue.main.async {
					totalSnapshotsSize.value = result
				}
			}
			
			if !manager.fileExists(atPath: snapshotsURL.path) {
				gdebug("Snapshots folder doesn't exist")
				return
			}
			
			do {
				let files = try manager.contentsOfDirectory(atPath: snapshotsURL.path)
				for file in files {
					let url = snapshotsURL.appendingPathComponent(file)
					if url.pathExtension != "szx" {
						continue
					}
					
					do {
						let attributes = try manager.attributesOfItem(atPath: url.path)
						if let size = attributes[FileAttributeKey.size] as? Int {
							result += size
						}
					}
				}
				
			} catch {
				gwarn("Failed determining snapshots size \(error)")
			}
		}
		
		gdebug("Starting snapshot calculation")
		snapshotCalculationWorkItem = item
		snapshotCalculationQueue.async(execute: item)
	}
	
	private static var snapshotCalculationWorkItem: DispatchWorkItem? = nil
	private static let snapshotCalculationQueue = DispatchQueue(label: "com.gentlebytes.ZXSpectrum.Snapshots")
}

// MARK: - Uploaded files handling

extension Database {
	
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

	/**
	Deletes all files and snapshots for the given object.
	*/
	@discardableResult
	static func deleteAllFiles(for object: FileObject) -> Bool {
		do {
			try deleteSnapshot(for: object)
		} catch {
			return false
		}
		
		return deleteFiles(at: object.url)
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
			// Determine files at source path. If single file, just copy that one directly, otherwise, create subfolder and copy all files in there.
			let fileURLs = try knownFileURLs(at: sourceURL)
			let destinationFolderURL = try destinationURL(at: filesURL, source: sourceURL, for: fileURLs)

			// Create destination folder.
			if !manager.fileExists(atPath: destinationFolderURL.path) {
				gdebug("Creating directory \(destinationFolderURL)")
				try manager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
			}
			
			// Copy all files.
			for fileURL in fileURLs {
				let filename = fileURL.lastPathComponent
				let destinationFileURL = destinationFolderURL.appendingPathComponent(filename)
				
				if manager.fileExists(atPath: destinationFileURL.path) {
					gdebug("Removing existing file at \(destinationFileURL)")
					try manager.removeItem(at: destinationFileURL)
				}
				
				gdebug("Moving \(fileURL) to \(destinationFileURL)")
				try manager.moveItem(at: fileURL, to: destinationFileURL)
			}
			
			return fileURLs.count == 1 ? fileURLs.first! : destinationFolderURL
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
	
	static private func deleteFiles(at url: URL) -> Bool {
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

	private static func knownFileURLs(at url: URL) throws -> [URL] {
		return try FileManager.default.contentsOfDirectory(atPath: url.path).filter { filename in
			let ext = (filename as NSString).pathExtension
			return allowedFileExtensions.contains(ext)
		}.map {
			return url.appendingPathComponent($0)
		}
	}
	
	private static func destinationURL(at baseURL: URL, source sourceURL: URL, for files: [URL]) throws -> URL {
		if files.count == 0 {
			gwarn("No known file found")
			throw NSError.move(description: NSLocalizedString("URL doesn't contain known file types!"))
		}
		
		let firstLetter = String(files.first!.lastPathComponent.characters.first!)
		
		// For single file use base path.
		if files.count == 1 {
			return baseURL.appendingPathComponent(firstLetter)
		}
		
		// For multiple files, use filename on top of base path so they are all grouped together. Note we use sourceURL as it's the "common" name in our use case.
		let filename = sourceURL.deletingPathExtension().lastPathComponent
		return baseURL.appendingPathComponent(firstLetter).appendingPathComponent(filename)
	}
}

// MARK: - Importing to database

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
