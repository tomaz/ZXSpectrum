//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation
import CoreData

final class FileObject: NSManagedObject {

	/// Path of the associated file. Note this is only filename and extension, without full path, use `url` to get full path to the tape file.
	@NSManaged var path: String
	
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
				return Database.filesURL.appendingPathComponent(path)
			}
		}
		set {
			path = newValue.lastPathComponent
		}
	}
	
	// MARK: - Overriden functions
	
	override func awakeFromInsert() {
		super.awakeFromInsert()
		
		setPrimitiveValue(Date(), forKey: #keyPath(added))
	}
}

// MARK: - Managed

extension FileObject: Managed {
	
	static var defaultSortDescriptors: [NSSortDescriptor] {
		return [
			NSSortDescriptor(key: #keyPath(used), ascending: false),
			NSSortDescriptor(key: #keyPath(added), ascending: false),
			NSSortDescriptor(key: #keyPath(path), ascending: true),
		]
	}
}

// MARK: - Fetching

extension FileObject {
	
	/**
	Returns predicate that filters stock objects only.
	*/
	static var stockPredicate: NSPredicate {
		return NSPredicate(format: "%K==true", #keyPath(isStock))
	}
}
