//
//  Created by Tomaz Kragelj on 21.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import SwiftRichString

final class Styles {
	
	/**
	Returns the style using default size.
	*/
	static func style(name: String? = nil, appearance: Appearance, size: Size) -> Style {
		return style(name: name, appearance: appearance, size: size.fontSize)
	}

	/**
	Returns the style for custom size.
	*/
	static func style(name: String? = nil, appearance: Appearance, size: CGFloat) -> Style {
		return Style(name ?? appearance.styleName, {
			$0.font = FontAttribute(font: UIFont.systemFont(ofSize: size, weight: appearance.fontWeight))!
			$0.color = appearance.fontColor
		})
	}

	/**
	Element apperance.
	*/
	struct Appearance: OptionSet {
		let rawValue: Int
		
		static let light = Appearance(rawValue: 1 << 0)
		static let emphasized = Appearance(rawValue: 1 << 1)
		static let inverted = Appearance(rawValue: 1 << 2)
		
		var styleName: String {
			if self.contains(.emphasized) {
				return "emphasized"
			} else {
				return "light"
			}
		}
		
		var fontWeight: CGFloat {
			if self.contains(.emphasized) {
				return UIFontWeightMedium
			} else {
				return UIFontWeightUltraLight
			}
		}
		
		var fontColor: UIColor {
			if self.contains(.inverted) {
				if self.contains(.emphasized) {
					return UIColor.white
				} else {
					return UIColor.white.withAlphaComponent(0.6)
				}
			} else {
				if self.contains(.emphasized) {
					return UIColor.darkText
				} else {
					return UIColor.lightGray
				}
			}
		}
	}
	
	/**
	Element size.
	*/
	enum Size {
		case main
		case info
		
		var fontSize: CGFloat {
			switch self {
			case .main:
				return UIDevice.iPhone ? 17 : 19
			case .info:
				return UIDevice.iPhone ? 14 : 16
			}
		}
	}
}
