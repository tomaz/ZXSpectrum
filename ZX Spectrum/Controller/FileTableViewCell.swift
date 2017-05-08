//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import SwiftRichString

class FileTableViewCell: UITableViewCell, Configurable {
	
	@IBOutlet fileprivate weak var nameLabel: UILabel!
	@IBOutlet fileprivate weak var insertButton: UIButton!
	@IBOutlet fileprivate weak var deleteButton: UIButton!
	@IBOutlet fileprivate weak var actionsContainerView: UIView!
	
	fileprivate var object: FileObject? = nil
	
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
		didRequestInsert = nil
		didRequestDelete = nil
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Hide or show actions if needed.
		let hide = !selected
		if actionsContainerView.isHidden != hide {
			UIView.animate(withDuration: 0.25) {
				self.actionsContainerView.isHidden = hide
				self.actionsContainerView.alpha = hide ? 0 : 1
			}
		}
		
		// Let table view know it needs to recalculate heights.
		if let tableView = tableView {
			tableView.beginUpdates()
			tableView.endUpdates()
		}
	}
}

// MARK: - Configurable

extension FileTableViewCell {
	
	func configure(object: FileObject) {
		gdebug("Configuring with \(object)")
		
		self.object = object
		
		nameLabel.attributedText = FileTableViewCell.text(for: object)
		nameLabel.lineBreakMode = .byTruncatingHead
	}
}

// MARK: - User interface

extension FileTableViewCell {
	
	fileprivate func setupInsertButtonSignals() {
		insertButton.reactive.tap.bind(to: self) { (me, sender) in
			if let object = self.object {
				ginfo("Inserting \(object)")
				self.didRequestInsert?(object)
			}
		}
	}
	
	fileprivate func setupDeleteButtonSignals() {
		deleteButton.reactive.tap.bind(to: self) { (me, sender) in
			if let object = self.object {
				ginfo("Deleting \(object)")
				self.didRequestDelete?(object)
			}
		}
	}
}

// MARK: - Styling

extension FileTableViewCell {

	/**
	Prepares the name text for the given object.
	*/
	fileprivate static func text(for object: FileObject) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		// Render (optional) path as light text.
		if !object.isStock, !object.path.isEmpty {
			let pathString = object.path.hasSuffix("/") ? object.path : "\(object.path)/"
			result.append(pathString.set(style: lightStyle))
		}
		
		// Render name as emphasized text.
		let url = object.url
		let filename = object.displayName
		result.append(filename.set(style: emphasizedStyle))
		
		// Render (optional) extension as light text (always render extension lowercase for nicer and less pronounced appearance)
		let ext = url.pathExtension
		if !ext.isEmpty {
			result.append(".\(ext)".lowercased().set(style: lightStyle))
		}
		
		return result
	}
	
	private static let lightStyle = Style("path", {
		$0.font = font(weight: UIFontWeightUltraLight)
		$0.color = UIColor.lightGray
	})
	
	private static let emphasizedStyle = Style("name", {
		$0.font = font(weight: UIFontWeightMedium)
		$0.color = UIColor.darkText
	})
	
	private static func font(weight: CGFloat) -> FontAttribute {
		let size: CGFloat = UIDevice.iPhone ? 17 : 19
		return FontAttribute(font: UIFont.systemFont(ofSize: size, weight: weight))!
	}
}
