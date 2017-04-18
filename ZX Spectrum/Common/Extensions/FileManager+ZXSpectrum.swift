//
//  Created by Tomaz Kragelj on 18.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

extension FileManager {
	
	/**
	Determines if the given path is a directory or not.
	*/
	func isDirectory(at path: String) -> Bool {
		var result: ObjCBool = false
		fileExists(atPath: path, isDirectory: &result)
		return result.boolValue
	}
	
	/**
	Size of the file at the given path.
	*/
	func size(of path: String) -> Int {
		do {
			let attributes = try attributesOfItem(atPath: path)
			guard let size = attributes[FileAttributeKey.size] as? Int else {
				return 0
			}
			return size
		} catch {
			return 0
		}
	}
}
