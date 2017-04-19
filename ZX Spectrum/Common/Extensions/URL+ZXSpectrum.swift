//
//  Created by Tomaz Kragelj on 19.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

extension URL {
	
	/**
	Returns the common prefix with the given url.
	
	If URLs have nothing in common, empty string is returned.
	*/
	func commonPrefix(with url: URL) -> String {
		return path.commonPrefix(with: url.path)
	}
	
	/**
	Returns the path that differs from the given string.
	
	If the two URLs have common prefix, this returns the path after that common prefix. Otherwise returns full path.
	*/
	func differentSuffix(with url: URL) -> String {
		let us = path
		let common = commonPrefix(with: url)
		
		if common.isEmpty {
			return us
		}
		
		let result = us.substring(from: us.index(us.startIndex, offsetBy: common.characters.count))
		if result.hasPrefix("/") {
			return result.substring(from: result.index(result.startIndex, offsetBy: 1))
		}
		
		return result
	}
}
