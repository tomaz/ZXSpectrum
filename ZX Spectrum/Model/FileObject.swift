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
	
	/// URL of the file. This always includes full path, also for stock files.
	var url: URL {
		get {
			if isStock {
				return Bundle.main.url(forResource: path, withExtension: nil)!
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
	
	// MARK: - Overriden functions
	
	override func awakeFromInsert() {
		super.awakeFromInsert()
		
		setPrimitiveValue(Date(), forKey: #keyPath(added))
	}
}

// MARK: - Managed & Core Data helpers

extension FileObject: Managed {
	
	static var defaultSortDescriptors: [NSSortDescriptor] {
		return [
			NSSortDescriptor(key: #keyPath(filename), ascending: true),
		]
	}
}
