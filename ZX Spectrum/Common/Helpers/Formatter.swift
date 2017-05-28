//
//  Created by Tomaz Kragelj on 21.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

final class Formatter {

	// MARK: - Size

	/**
	Prepares formatted size value and unit from given amount of bytes.
	*/
	static func size(fromBytes bytes: Int) -> (value: String, unit: String) {
		let string = sizeFormatter.string(fromByteCount: Int64(bytes))
		let components = string.components(separatedBy: " ")
		return (components[0], components[1])
	}

	private static let sizeFormatter: ByteCountFormatter = {
		let result = ByteCountFormatter()
		result.allowedUnits = [ .useBytes, .useKB ]
		result.includesUnit = true
		return result
	}()

	
	// MARK: - Number
	
	/**
	Converts the given time in milliseconds into value and unit tuple.
	*/
	static func time(fromMilliseconds value: Int) -> (value: String, unit: String) {
		return time(fromSeconds: Double(value) / 1000.0)
	}
	
	/**
	Converts the given time in seconds into value and unit tuple.
	*/
	static func time(fromSeconds value: Double) -> (value: String, unit: String) {
		if let string = timeFormatter.string(for: value) {
			return (string, NSLocalizedString("s"))
		}
		return ("0", NSLocalizedString("s"))
	}
	
	private static let timeFormatter: NumberFormatter = {
		let result = NumberFormatter()
		result.minimumFractionDigits = 0
		result.maximumFractionDigits = 1
		return result
	}()
}
