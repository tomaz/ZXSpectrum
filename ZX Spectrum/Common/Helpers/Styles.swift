//
//  Created by Tomaz Kragelj on 21.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import SwiftRichString

final class Styles {
	
	/**
	Converts the given string into attributed string using the given styles.
	*/
	static func text(from string: String, styles: [Style]) -> NSAttributedString? {
		let markup = try! MarkupString(source: string, styles: styles)
		return markup.render(withStyles: styles)
	}
	
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
		static let semiEmphasized = Appearance(rawValue: 1 << 2)
		static let inverted = Appearance(rawValue: 1 << 3)
		
		var styleName: String {
			if contains(.emphasized) {
				return "emphasized"
			} else if contains(.semiEmphasized) {
				return "semi-emphasized"
			} else {
				return "light"
			}
		}
		
		var fontWeight: CGFloat {
			if contains(.emphasized) || contains(.semiEmphasized) {
				return UIFontWeightMedium
			} else {
				return UIFontWeightUltraLight
			}
		}
		
		var fontColor: UIColor {
			if contains(.inverted) {
				if contains(.emphasized) || contains(.semiEmphasized) {
					return UIColor.white
				} else {
					return UIColor.white.withAlphaComponent(0.6)
				}
			} else {
				if contains(.emphasized) {
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
		case title
		case main
		case info
		
		var fontSize: CGFloat {
			switch self {
			case .title: return UIDevice.iPhone ? 19 : 22
			case .main: return UIDevice.iPhone ? 17 : 19
			case .info: return UIDevice.iPhone ? 14 : 16
			}
		}
	}
}
