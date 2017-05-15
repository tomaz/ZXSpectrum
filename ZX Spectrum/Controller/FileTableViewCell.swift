//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import SwiftRichString

class FileTableViewCell: UITableViewCell, Configurable {
	
	@IBOutlet fileprivate weak var nameLabel: UILabel!
	@IBOutlet fileprivate weak var basicInfoLabel: UILabel!
	@IBOutlet fileprivate weak var detailedInfoLabel: UILabel!
	@IBOutlet fileprivate weak var insertButton: UIButton!
	@IBOutlet fileprivate weak var deleteButton: UIButton!
	@IBOutlet fileprivate weak var actionsContainerView: UIView!
	
	fileprivate lazy var controller = SpectrumFileController()
	
	fileprivate var object: FileObject? = nil
	fileprivate var info: SpectrumFileInfo? = nil
	
	// MARK: - Callbacks

	/// Called when user selects to insert the object for playback.
	var didRequestInsert: ((FileObject) -> Void)? = nil
	
	/// Called when user wants to delete the object
	var didRequestDelete: ((FileObject) -> Void)? = nil
	
	// MARK: - Overriden functions
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		insertButton.image = IconsStyleKit.imageOfIconInsert
		deleteButton.image = IconsStyleKit.imageOfIconTrash
		
		actionsContainerView.isHidden = true
		actionsContainerView.alpha = 0
		
		setupInsertButtonSignals()
		setupDeleteButtonSignals()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		object = nil
		info = nil
		
		didRequestInsert = nil
		didRequestDelete = nil
		
		basicInfoLabel.text = nil
		detailedInfoLabel.isHidden = true
		actionsContainerView.isHidden = true
	}
}

// MARK: - Configurable

extension FileTableViewCell {
	
	func configure(object: FileObject) {
		gdebug("Configuring with \(object)")
		
		self.object = object
		
		nameLabel.attributedText = FileTableViewCell.text(for: object)
		nameLabel.lineBreakMode = .byTruncatingHead
		
		select(selected: isSelected, animated: false)
	}
}

// MARK: - User interface

extension FileTableViewCell {
	
	/**
	Selects on unselects the cell.
	*/
	func select(selected: Bool = true, animated: Bool = true) {
		func handler() {
			basicInfoLabel.isHidden = !selected || (basicInfoLabel.text?.isEmpty ?? true)
			detailedInfoLabel.isHidden = !selected || (detailedInfoLabel.text?.isEmpty ?? true)
			actionsContainerView.isHidden = !selected
			actionsContainerView.alpha = selected ? 1 : 0
		}
		
		if selected, info == nil, let object = object {
			do {
				info = try controller.informationForFile(atPath: object.url.path)
				if let info = info {
					basicInfoLabel.attributedText = FileTableViewCell.basicInfo(for: object, fileInfo: info)
					detailedInfoLabel.attributedText = FileTableViewCell.detailedInfo(for: object, fileInfo: info)
				} else {
					basicInfoLabel.text = nil
					detailedInfoLabel.text = nil
				}
			} catch {
				gwarn("Failed reading info for \(object): \(error)")
			}
		}
		
		// Handle non-animated.
		if !animated {
			handler()
			return
		}
		
		// Hide or show actions if needed.
		let hide = !selected
		if actionsContainerView.isHidden != hide {
			UIView.animate(withDuration: 0.25) {
				handler()
			}
		}
		
		// Let table view know it needs to recalculate heights.
		if let tableView = tableView {
			tableView.beginUpdates()
			tableView.endUpdates()
		}
	}
	
	fileprivate func setupInsertButtonSignals() {
		insertButton.reactive.tap.bind(to: self) { me, sender in
			if let object = me.object {
				ginfo("Inserting \(object)")
				me.didRequestInsert?(object)
			}
		}
	}
	
	fileprivate func setupDeleteButtonSignals() {
		deleteButton.reactive.tap.bind(to: self) { me, sender in
			if let object = me.object {
				ginfo("Deleting \(object)")
				me.didRequestDelete?(object)
			}
		}
	}
}

// MARK: - Name styling

extension FileTableViewCell {

	/**
	Prepares the name text for the given object.
	*/
	fileprivate static func text(for object: FileObject) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		// Render (optional) path as light text.
		if !object.isStock, !object.path.isEmpty {
			let pathString = object.path.hasSuffix("/") ? object.path : "\(object.path)/"
			let string = pathString.deleting(prefix: ".")
			result.append(string.set(style: textLightStyle))
		}
		
		// Render name as emphasized text.
		let url = object.url
		let filename = object.displayName
		result.append(filename.set(style: textEmphasizedStyle))
		
		// Render (optional) extension as light text (always render extension lowercase for nicer and less pronounced appearance)
		let ext = url.pathExtension
		if !ext.isEmpty {
			result.append(".\(ext)".lowercased().set(style: textLightStyle))
		}
		
		return result
	}
	
	private static let textLightStyle = lightStyle(size: .title)
	private static let textEmphasizedStyle = emphasizedStyle(size: .title)
}

// MARK: - Info styling

extension FileTableViewCell {

	/**
	Prepares basic info text for the given object.
	*/
	fileprivate static func basicInfo(for object: FileObject, fileInfo: SpectrumFileInfo) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		if fileInfo.size > 0 {
			let values = size(fromBytes: fileInfo.size)
			let text = info(title: NSLocalizedString("Size"), values: [values.value], suffix: values.unit)
			result.appendLine(text)
		}
		
		if fileInfo.blocksCount > 0 {
			let text = info(title: NSLocalizedString("Blocks"), values: ["\(fileInfo.blocksCount)"])
			result.appendLine(text)
		}
		
		return tabbed(string: result)
	}
	
	/**
	Prepares detailed text for the given object.
	*/
	fileprivate static func detailedInfo(for object: FileObject, fileInfo: SpectrumFileInfo) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for item in items(for: fileInfo) {
			let text = info(title: item.title, values: item.values)
			result.appendLine(text)
		}
		
		return tabbed(string: result)
	}
	
	private static func tabbed(string: NSMutableAttributedString) -> NSAttributedString {
		if string.string.contains("\t") {
			let indent = CGFloat(UIDevice.iPhone ? 90 : 125)
			
			let style = NSMutableParagraphStyle()
			style.headIndent = indent // indent second and subsequent lines to tab stop
			style.tabStops = [ NSTextTab(textAlignment: .left, location: indent, options: [:]) ]
			
			string.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: string.length))
		}
		return string
	}
	
	private static func info(title: String, values: [String]? = nil, suffix: String? = nil) -> NSAttributedString {
		let result = NSMutableAttributedString()
		var didAddDelimiter = false
		var didAddValue = false
		
		func addDelimiter() {
			if didAddDelimiter {
				return
			}
			result.append("\t".set(style: infoLightStyle))
			didAddDelimiter = true
		}
		
		result.append(title.set(style: infoLightStyle))
		
		if let values = values {
			addDelimiter()
			for (index, value) in values.enumerated() {
				if index > 0 {
					result.append(", ".set(style: infoLightStyle))
				}
				result.append(value.set(style: infoEmphasizedStyle))
			}
			didAddValue = true
		}
		
		if let suffix = suffix {
			addDelimiter()
			if didAddValue {
				result.append(" ".set(style: infoLightStyle))
			}
			result.append(suffix.set(style: infoLightStyle))
		}
		
		return result
	}
	
	private static func items(for info: SpectrumFileInfo) -> [(title: String, values: [String])] {
		var result = [(String, [String])]()
		if let values = info.authors {
			let title = values.count > 1 ? NSLocalizedString("Authors") : NSLocalizedString("Author")
			result.append((title, values))
		}
		if let value = info.publisher {
			result.append((NSLocalizedString("Publisher"), [value]))
		}
		if let value = info.year {
			result.append((NSLocalizedString("Year"), [value]))
		}
		if let value = info.price {
			result.append((NSLocalizedString("Price"), [value]))
		}
		if let value = info.type {
			result.append((NSLocalizedString("Type"), [value]))
		}
		if let value = info.language {
			result.append((NSLocalizedString("Language"), [value]))
		}
		if let value = info.loader {
			result.append((NSLocalizedString("Loader"), [value]))
		}
		if let value = info.origin {
			result.append((NSLocalizedString("Origin"), [value]))
		}
		if let value = info.comment {
			result.append((NSLocalizedString("Comment"), [value]))
		}
		return result
	}

	private static func size(fromBytes bytes: Int) -> (value: String, unit: String) {
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
	
	private static let infoLightStyle = lightStyle(size: .info)
	private static let infoEmphasizedStyle = emphasizedStyle(size: .info)
}

// MARK: - Common styling

extension FileTableViewCell {
	
	fileprivate static func lightStyle(size: Size) -> SwiftRichString.Style {
		return style(name: "light", style: .light, size: size)
	}
	
	fileprivate static func emphasizedStyle(size: Size) -> SwiftRichString.Style {
		return style(name: "emphasized", style: .emphasized, size: size)
	}

	fileprivate static func style(name: String, style: Style, size: Size) -> SwiftRichString.Style {
		return SwiftRichString.Style(name, {
			$0.font = FontAttribute(font: UIFont.systemFont(ofSize: size.fontSize, weight: style.fontWeight))!
			$0.color = style.fontColor
		})
	}
	
	fileprivate enum Style {
		case light
		case emphasized
		
		var fontWeight: CGFloat {
			switch self {
			case .light:
				return UIFontWeightUltraLight
			case .emphasized:
				return UIFontWeightMedium
			}
		}
		
		var fontColor: UIColor {
			switch self {
			case .light:
				return UIColor.lightGray
			case .emphasized:
				return UIColor.darkText
			}
		}
	}
	
	fileprivate enum Size {
		case title
		case info
		
		var fontSize: CGFloat {
			switch self {
			case .title:
				return UIDevice.iPhone ? 17 : 19
			case .info:
				return UIDevice.iPhone ? 14 : 16
			}
		}
	}
}
