//
//  Created by Tomaz Kragelj on 8.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Manages palette of Spectrum colors.
*/
final class SpectrumPalette: NSObject {
	
	/**
	Let's keep this on English spelling in honor of Speccy origin :)
	*/
	private let colours: [Color]
	
	/**
	Well, and here as well :))
	*/
	private init(colours: [Color]) {
		self.colours = colours
	}

	/**
	Returns the color at the given index.
	*/
	subscript(index: Int) -> Color {
		return colours[index]
	}
	
	/**
	Helper methods for Objective-C.
	*/
	@objc(rawColorAtIndex:)
	func raw(at index: Int) -> UInt32 {
		return colours[index].raw;
	}

	/**
	Colored palette.
	*/
	static let colored: SpectrumPalette = {
		let a = CGFloat(0.74193548)
		let b = CGFloat(1)
		
		return SpectrumPalette(colours: [
			Color(red: 0, green: 0, blue: 0, alpha: 1),
			Color(red: 0, green: 0, blue: a, alpha: 1),
			Color(red: a, green: 0, blue: 0, alpha: 1),
			Color(red: a, green: 0, blue: a, alpha: 1),
			Color(red: 0, green: a, blue: 0, alpha: 1),
			Color(red: 0, green: a, blue: a, alpha: 1),
			Color(red: a, green: a, blue: 0, alpha: 1),
			Color(red: a, green: a, blue: a, alpha: 1),
			
			Color(red: 0, green: 0, blue: 0, alpha: 1),
			Color(red: 0, green: 0, blue: b, alpha: 1),
			Color(red: b, green: 0, blue: 0, alpha: 1),
			Color(red: b, green: 0, blue: b, alpha: 1),
			Color(red: 0, green: b, blue: 0, alpha: 1),
			Color(red: 0, green: b, blue: b, alpha: 1),
			Color(red: b, green: b, blue: 0, alpha: 1),
			Color(red: b, green: b, blue: b, alpha: 1),
		])
	}()
	
	/**
	Black and white palette.
	*/
	static let blackAndWhite: SpectrumPalette = {
		var colors = [Color]()
		for color in colored.colours {
			let argb = color.argb
			let grey = 0.299 * CGFloat(argb[1]) / 255.0 + 0.587 * CGFloat(argb[2]) / 255.0 + 0.114 * CGFloat(argb[3]) / 255.0
			colors.append(Color(red: grey, green: grey, blue: grey, alpha: 1))
		}
		return SpectrumPalette(colours: colors)
	}()

	/**
	Returns either colors or black and white palette.
	*/
	static func palette(color: Bool) -> SpectrumPalette {
		return color ? colored : blackAndWhite
	}
}

// MARK: - Declarations

extension SpectrumPalette {
	
	final class Color {
		let color: UIColor
		let argb: [UInt8]
		let raw: UInt32
		
		fileprivate init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
			let a = UInt8(alpha * 255)
			let r = UInt8(red * 255)
			let g = UInt8(green * 255)
			let b = UInt8(blue * 255)
			
			self.color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
			
			self.argb = [ a, r, g, b ]
			
			self.raw = UInt32(a) << 24 + UInt32(r) << 16 + UInt32(g) << 8 + UInt32(b)
		}
	}
}

// MARK: - Extensions

extension Array {
	
	var toUInt8Array: [UInt8] {
		var result = [UInt8]()
		for element in self {
			let word = element as! UInt32
			result.append(UInt8((word >> 24) & 0xFF))
			result.append(UInt8((word >> 16) & 0xFF))
			result.append(UInt8((word >> 8) & 0xFF))
			result.append(UInt8(word & 0xFF))
		}
		return result
	}
}
