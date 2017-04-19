//
//  Created by Tomaz Kragelj on 19.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

// MARK: - Formatting

extension String {
	
	/**
	Converts the given strings into single string, represented as paragraphs.
	*/
	init(paragraphs: String...) {
		self.init(paragraphs: paragraphs)
	}
	
	/**
	Converts the given array of strings into single string, represented as paragraphs.
	*/
	init(paragraphs: [String]) {
		self.init(paragraphs.joined(separator: "\n\n"))!
	}
	
	/**
	Converts the given strings into single string, represented as line items.
	*/
	init(lines: String...) {
		self.init(lines: lines)
	}
	
	/**
	Converts the given array of strings into single string, represented as line items.
	*/
	init(lines: [String], prefixIfSingle: Bool = false) {
		let value: String
		
		if lines.count > 1 || prefixIfSingle {
			value = "- " + lines.joined(separator: "\n- ")
		} else {
			value = lines.first ?? ""
		}
		
		self.init(value)!
	}
}

// MARK: - Converting

extension String {
	
	/**
	Converts the string into an array of `Int8` bytes, terminated by 0; useful for passing to C functions expecting `char *`.
	*/
	var toInt8Array: [Int8] {
		var result = [Int8]()
		for byte in utf8 {
			result.append(Int8(byte))
		}
		result.append(Int8(0))
		return result
	}
}
