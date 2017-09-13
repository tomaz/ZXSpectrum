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
	@IBOutlet fileprivate weak var hardwareInfoLabel: UILabel!
	@IBOutlet fileprivate weak var insertButton: UIButton!
	@IBOutlet fileprivate weak var deleteButton: UIButton!
	@IBOutlet fileprivate weak var deleteSnapshotButton: UIButton!
	@IBOutlet fileprivate weak var actionsContainerView: UIView!
	
	fileprivate lazy var controller = SpectrumFileController()
	
	fileprivate var object: FileObject? = nil
	fileprivate var info: SpectrumFileInfo? = nil
	fileprivate var snapshotSize: Int = 0
	
	// MARK: - Callbacks

	/// Called when user selects to insert the object for playback.
	var didRequestInsert: ((FileObject, SpectrumFileInfo?) -> Void)? = nil
	
	/// Called when user wants to delete all files associated with the object.
	var didRequestDelete: ((FileObject) -> Void)? = nil
	
	// MARK: - Overriden functions
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		insertButton.image = IconsStyleKit.imageOfIconInsert
		deleteButton.image = IconsStyleKit.imageOfIconTrash
		deleteSnapshotButton.image = IconsStyleKit.imageOfIconTrashSnapshot
		
		actionsContainerView.isHidden = true
		actionsContainerView.alpha = 0
		
		setupInsertButtonSignals()
		setupDeleteButtonSignals()
		setupDeleteSnapshotButtonSignals()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		object = nil
		info = nil
		snapshotSize = 0
		
		didRequestInsert = nil
		didRequestDelete = nil
		
		basicInfoLabel.text = nil
		detailedInfoLabel.isHidden = true
		hardwareInfoLabel.isHidden = true
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
		updateDetails(selected: selected, animated: animated, forced: false)
	}
	
	fileprivate func updateDetails(selected: Bool = true, animated: Bool = true, forced: Bool = false) {
		func handler() {
			basicInfoLabel.isHidden = !selected || (basicInfoLabel.text?.isEmpty ?? true)
			detailedInfoLabel.isHidden = !selected || (detailedInfoLabel.text?.isEmpty ?? true)
			hardwareInfoLabel.isHidden = !selected || (hardwareInfoLabel.text?.isEmpty ?? true)
			deleteSnapshotButton.isHidden = snapshotSize == 0
			actionsContainerView.isHidden = !selected
			actionsContainerView.alpha = selected ? 1 : 0
		}
		
		// If selected and info isn't prepared yet, do it now.
		if selected, forced || info == nil, let object = object {
			do {
				info = try controller.informationForFile(atPath: object.url.path)
				snapshotSize = Database.snapshotSize(for: object)
				if let info = info {
					basicInfoLabel.attributedText = FileTableViewCell.basicInfo(for: object, fileInfo: info, snapshotSize: snapshotSize)
					detailedInfoLabel.attributedText = FileTableViewCell.detailedInfo(for: object, fileInfo: info)
					hardwareInfoLabel.attributedText = FileTableViewCell.hardwareInfo(for: object, fileInfo: info)
					deleteButton.attributedTitle = FileTableViewCell.deleteAllText(for: object, fileInfo: info, snapshotSize: snapshotSize)
					deleteSnapshotButton.attributedTitle = FileTableViewCell.deleteSnapshotText(for: object, fileInfo: info, snapshotSize: snapshotSize)
				} else {
					basicInfoLabel.text = nil
					detailedInfoLabel.text = nil
					hardwareInfoLabel.text = nil
					deleteButton.attributedTitle = nil
					deleteSnapshotButton.attributedTitle = nil
				}
			} catch {
				gwarn("Failed reading info for \(object): \(error)")
			}
		}
		
		// If unselecting, cleanup memory used by the file.
		if !selected {
			info = nil
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
				me.didRequestInsert?(object, me.info)
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
	
	fileprivate func setupDeleteSnapshotButtonSignals() {
		deleteSnapshotButton.reactive.tap.bind(to: self) { me, sender in
			if let object = me.object {
				ginfo("Deleting snapshots for \(object)")
				Alert.deleteSnapshot(for: object) { error in
					if let error = error {
						UIViewController.current.present(error: error)
						return
					}
					UIView.animate(withDuration: 0.25) {
						me.updateDetails(forced: true)
						me.deleteSnapshotButton.isHidden = true
					}
				}
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
	
	private static let textLightStyle = lightStyle(size: .main)
	private static let textEmphasizedStyle = emphasizedStyle(size: .main)
}

// MARK: - Info styling

extension FileTableViewCell {

	/**
	Prepares basic info text for the given object.
	*/
	fileprivate static func basicInfo(for object: FileObject, fileInfo: SpectrumFileInfo, snapshotSize: Int) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		if fileInfo.size > 0 {
			let values = Formatter.size(fromBytes: fileInfo.size)
			let text = info(title: NSLocalizedString("Size"), values: [values.value], suffix: values.unit)
			result.appendLine(text)
		}
		
		if snapshotSize > 0 {
			let values = Formatter.size(fromBytes: snapshotSize)
			let text = info(title: NSLocalizedString("Snapshot"), values: [values.value], suffix: values.unit)
			result.appendLine(text)
		}
		
		if !fileInfo.blocks.isEmpty {
			let text = info(title: NSLocalizedString("Blocks"), values: ["\(fileInfo.blocks.count)"])
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
	
	/**
	Prepares hardware info text for the given object.
	*/
	fileprivate static func hardwareInfo(for object: FileObject, fileInfo: SpectrumFileInfo) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for item in hardwareItems(for: fileInfo) {
			let text = hardwareInfo(for: item)
			result.appendLine(text)
		}
		
		return result
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
	
	private static func hardwareInfo(for item: (usage: String, hardware: String)) -> NSAttributedString {
		return
			item.usage.set(style: infoLightStyle) +
			" ".set(style: infoLightStyle) +
			item.hardware.set(style: infoSemiEmphasizedStyle)
	}
	
	private static func hardwareItems(for info: SpectrumFileInfo) -> [(usage: String, hardware: String)] {
		var result = [(String, String)]()
		for info in info.hardwareInfo {
			switch info.usage {
			case .runs: result.append((NSLocalizedString("Runs on"), info.identifier))
			case .runsButDoesntUseSpecialFeatures: result.append((NSLocalizedString("Runs on"), info.identifier))
			case .usesSpecialFeatures: result.append((NSLocalizedString("Requires"), info.identifier))
			case .doesntRun: result.append((NSLocalizedString("Doesn't run on"), info.identifier))
			}
		}
		return result
	}
	
	private static let infoLightStyle = lightStyle(size: .info)
	private static let infoEmphasizedStyle = emphasizedStyle(size: .info)
	private static let infoSemiEmphasizedStyle = style(appearance: .semiEmphasized, size: .info)
}

// MARK: - Actions styling

extension FileTableViewCell {
	
	/**
	Prepares delete all files text.
	*/
	fileprivate static func deleteAllText(for object: FileObject, fileInfo: SpectrumFileInfo, snapshotSize: Int) -> NSAttributedString? {
		// If there's no snapshot, only show icon.
		if snapshotSize == 0 {
			return nil
		}
		
		let totalSize = fileInfo.size + snapshotSize
		let value = Formatter.size(fromBytes: totalSize)
		
		let result = NSMutableAttributedString()
		result.append(value.value.set(style: FileTableViewCell.buttonValueStyle))
		result.append(value.unit.set(style: FileTableViewCell.buttonStyle))
		return result
	}
	
	/**
	Prepares delete snapshot title.
	*/
	fileprivate static func deleteSnapshotText(for object: FileObject, fileInfo: SpectrumFileInfo, snapshotSize: Int) -> NSAttributedString? {
		if snapshotSize == 0 {
			return nil
		}
		
		let value = Formatter.size(fromBytes: snapshotSize)
		
		let result = NSMutableAttributedString()
		result.append(value.value.set(style: FileTableViewCell.buttonValueStyle))
		result.append(value.unit.set(style: FileTableViewCell.buttonStyle))
		return result
	}
	
	private static let buttonStyle = style(appearance: [.light, .warning], size: .main)
	private static let buttonValueStyle = style(appearance: [.emphasized, .warning], size: .main)
}

// MARK: - Common styling

extension FileTableViewCell {
	
	fileprivate static func lightStyle(size: Styles.Size) -> Style {
		return style(appearance: .light, size: size)
	}
	
	fileprivate static func emphasizedStyle(size: Styles.Size) -> Style {
		return style(appearance: .emphasized, size: size)
	}

	fileprivate static func style(appearance: Styles.Appearance, size: Styles.Size) -> Style {
		return Styles.style(appearance: appearance, size: size)
	}
}
