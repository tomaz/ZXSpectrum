//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation
import CoreData

final class FileObject: NSManagedObject {

	/// Path from base folder of the associated file (either main bundle or files, depending whether this is stock or uploaded file). Use `url` to get absolute path.
	@NSManaged var path: String
	
	/// Filename of the object. Use `url` to get absolute path.
	@NSManaged var filename: String
	
	/// Date file was added to library.
	@NSManaged var added: Date
	
	/// Date file was last used or nil if file wasn't used yet.
	@NSManaged var used: Date?
	
	/// Specifies whether the object is stock or uploaded.
	@NSManaged var isStock: Bool
	
	/// Mapping for joystick up or nil if none.
	@NSManaged fileprivate var mappingUp: NSNumber?
	
	/// Mapping for joystick down or nil if none.
	@NSManaged fileprivate var mappingDown: NSNumber?
	
	/// Mapping for joystick left or nil if none.
	@NSManaged fileprivate var mappingLeft: NSNumber?
	
	/// Mapping for joystick right or nil if none.
	@NSManaged fileprivate var mappingRight: NSNumber?
	
	/// Mapping for joystick fire or nil if none.
	@NSManaged fileprivate var mappingFire: NSNumber?
	
	// MARK: - Helper properties
	
	/// Indicates whether last uploaded files were succesfully deleted. Only valid after deleting the object.
	fileprivate (set) var didUploadedFilesDelete = false
	
	// MARK: - Overriden functions
	
	override func awakeFromInsert() {
		super.awakeFromInsert()
		
		setPrimitiveValue(Date(), forKey: #keyPath(added))
	}

	override func prepareForDeletion() {
		super.prepareForDeletion()
		didUploadedFilesDelete = Database.deleteUploadedFiles(at: url)
	}
}

// MARK: - Derived properties

extension FileObject {
	
	/// Mapped joystick up key.
	var joystickUpKey: KeyCode? {
		get { return getKeyCode(from: mappingUp) }
		set { mappingUp = set(keyCode: newValue) }
	}
	
	/// Mapped joystick down key.
	var joystickDownKey: KeyCode? {
		get { return getKeyCode(from: mappingDown) }
		set { mappingDown = set(keyCode: newValue) }
	}
	
	/// Mapped joystick keft key.
	var joystickLeftKey: KeyCode? {
		get { return getKeyCode(from: mappingLeft) }
		set { mappingLeft = set(keyCode: newValue) }
	}
	
	/// Mapped joystick right key.
	var joystickRightKey: KeyCode? {
		get { return getKeyCode(from: mappingRight) }
		set { mappingRight = set(keyCode: newValue) }
	}
	
	/// Mapped joystick fire key.
	var joystickFireKey: KeyCode? {
		get { return getKeyCode(from: mappingFire) }
		set { mappingFire = set(keyCode: newValue) }
	}
	
	/// First letter of the `filename`.
	var letter: String {
		return String(filename.characters.first!)
	}

	/// Only the file name of this object, without extension; suitable for displaying on screen.
	var displayName: String {
		return relativeURL.deletingPathExtension().lastPathComponent
	}
	
	/// URL of the file. This always includes full path, also for stock files.
	var url: URL {
		get {
			if isStock {
				return Bundle.main.url(forResource: filename, withExtension: nil)!
			} else {
				return Database.filesURL.appendingPathComponent(path).appendingPathComponent(filename)
			}
		}
		set {
			path = newValue.deletingLastPathComponent().relativePath
			filename = newValue.lastPathComponent
		}
	}
	
	/// Relative URL from base path.
	var relativeURL: URL {
		if path.isEmpty {
			return URL(fileURLWithPath: filename)
		} else {
			return URL(fileURLWithPath: path).appendingPathComponent(filename)
		}
	}
	
	private func getKeyCode(from number: NSNumber?) -> KeyCode? {
		if let number = number {
			return KeyCode(rawValue: number.uint32Value)
		}
		return nil
	}
	
	private func set(keyCode: KeyCode?) -> NSNumber? {
		if let code = keyCode {
			return NSNumber(value: code.rawValue)
		}
		return nil
	}
}

// MARK: - Managed & Core Data helpers

extension FileObject: Managed {
	
	static var defaultSortDescriptors: [NSSortDescriptor] {
		return [
			NSSortDescriptor(key: #keyPath(filename), ascending: true),
		]
	}
	
	/**
	Array of properties used to describe object path.
	*/
	static var pathProperties: [Any] {
		return [ #keyPath(path), #keyPath(filename) ]
	}
	
	/**
	Returns predicate for filtering either for stock or uploaded objects.
	*/
	static func predicate(stock: Bool) -> NSPredicate {
		if stock {
			return NSPredicate(format: "%K==true", #keyPath(isStock))
		} else {
			return NSPredicate(format: "%K==false", #keyPath(isStock))
		}
	}
}

// MARK: - Helper functions

extension FileObject {
	
	/**
	Deletes the object from managed object context and all associated files.
	
	Note: this is convenience function only; we can also use `delete()` and check `didUploadedFilesDelete` afterwards.
	*/
	func deleteObjectAndAssociatedFiles() -> Bool {
		delete()
		return didUploadedFilesDelete
	}
}
