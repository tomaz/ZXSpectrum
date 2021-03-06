//
//  Created by Tomaz Kragelj on 20.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import SwiftRichString

final class TapeBlockTableViewCell: UITableViewCell, Configurable {
	
	@IBOutlet fileprivate weak var indexLabel: UILabel!
	@IBOutlet fileprivate weak var descriptionLabel: UILabel!
	@IBOutlet fileprivate weak var progressView: VerticalProgressView!
	
	// MARK: - Data
	
	fileprivate var representedBlock: SpectrumFileBlock?
	
	// MARK: - Configurable
	
	func configure(object: SpectrumFileBlock) {
		gdebug("Configuring with \(object)")
		representedBlock = object
		indexLabel.attributedText = description(forIndex: object.index)
		descriptionLabel.attributedText = description(forBlock: object)
		progressView.progress = progress()
	}
	
	// MARK: - Overriden functions
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		Defaults.isTapePlaying.bind(to: self) { me, value in
			gverbose("Tape playback status changed to \(value)")
			me.progressView.isHidden = !value
		}
		
		Defaults.tapePlaybackBlock.observeOn(DispatchQueue.main).bind(to: self) { me, value in
			gverbose("Tape block changed to \(value)")
			me.progressView.progress = me.progress()
		}
		
		Defaults.tapePlaybackBlockCompletionRatio.observeOn(DispatchQueue.main).bind(to: self) { me, value in
			me.handleBlock { block in
				me.progressView.progress = value
			}
		}
	}
}

// MARK: - Playback

extension TapeBlockTableViewCell {
	
	/**
	Calls the given handler if our represented block is the one currently playing.
	*/
	fileprivate func handleBlock(handler: (SpectrumFileBlock) -> Void) {
		if let block = representedBlock, block.index == Defaults.tapePlaybackBlock.value {
			handler(block)
		}
	}
	
	/**
	Returns progress value based on current values.
	*/
	fileprivate func progress() -> CGFloat {
		if let block = representedBlock, Defaults.isTapePlaying.value {
			let currentBlock = Defaults.tapePlaybackBlock.value
			if block.index < currentBlock {
				// Past blocks should be rendered complete.
				return 1
			} else if block.index == currentBlock {
				// Current block should be rendered by current value.
				return Defaults.tapePlaybackBlockCompletionRatio.value
			} else {
				// Future blocks should be rendered as incomplete.
				return 0
			}
		} else {
			// If block is not assigned, show 0 progress.
			return 0
		}
	}
}

// MARK: - Formatting

extension TapeBlockTableViewCell {
	
	fileprivate func description(forIndex index: Int) -> NSAttributedString {
		return "\(index + 1).".set(style: TapeBlockTableViewCell.textStyle)
	}
	
	fileprivate func description(forBlock block: SpectrumFileBlock) -> NSAttributedString? {
		let description = block.localizedDescription
		
		if block.block.type == LIBSPECTRUM_TAPE_BLOCK_PAUSE {
			return dataText(prefix: description, length: 0, pause: block.block.types.pause.length)
		} else if let details = block.localizedDetails {
			// If first details value is number, use it as value and remainder as unit.
			if details.count >= 2, let size = Int(details[0]) {
				return dataText(prefix: description, length: size)
			}
			
			// If we have multiple components, take first as description and remaining ones as value.
			if details.count >= 2 {
				let value = details.dropFirst().joined(separator: " ")
				return text(prefix: details[0], value: value)
			}
		
			// Otherwise take all components as single value string.
			let value = details.count > 0 ? details.joined(separator: " ") : nil
			return text(prefix: description, value: value)
		}
		
		return text(prefix: description)
	}

	private func dataText(prefix: String, length: Int, pause: libspectrum_dword = 0) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		if length > 0 {
			let size = Formatter.size(fromBytes: length)
			result.append(TapeBlockTableViewCell.text(prefix: prefix, value: size.value, unit: size.unit)!)
			if pause > 0 {
				let time = Formatter.time(fromMilliseconds: Int(pause))
				result.append(", ".set(style: TapeBlockTableViewCell.textStyle))
				result.append(TapeBlockTableViewCell.text(prefix: NSLocalizedString("pause"), value: time.value, unit: time.unit)!)
			}
		} else {
			let time = Formatter.time(fromMilliseconds: Int(pause))
			result.append(TapeBlockTableViewCell.text(prefix: prefix, value: time.value, unit: time.unit)!)
		}
		
		return result
	}
	
	private func text(prefix: String? = nil, value: String? = nil, unit: String? = nil) -> NSAttributedString? {
		// This is just shortcut for static function, makes usage shorter and unified with `dataText(prefix:legth:pause:)`.
		return TapeBlockTableViewCell.text(prefix: prefix, value: value, unit: unit)
	}
}

// MARK: - Styling

extension TapeBlockTableViewCell {

	fileprivate static func text(prefix: String? = nil, value: String? = nil, unit: String? = nil) -> NSAttributedString? {
		if prefix == nil && value == nil && unit == nil {
			return nil
		}
		
		let result = NSMutableAttributedString()
		
		if let prefix = prefix {
			let prefixValue = prefix.hasSuffix(":") ? prefix.substring(to: prefix.index(before: prefix.endIndex)) : prefix
			result.append(prefixValue.set(style: textStyle))
			if value != nil || unit != nil {
				result.append(": ".set(style: textStyle))
			}
		}
		
		if let value = value {
			result.append(value.set(style: valueStyle))
			if unit != nil {
				result.append(" ".set(style: valueStyle))
			}
		}
		
		if let unit = unit {
			result.append(unit.set(style: textStyle))
		}
		
		return result
	}
	
	fileprivate static let valueStyle = Styles.style(appearance: [.emphasized, .inverted], size: .main)
	fileprivate static let textStyle = Styles.style(appearance: [.light, .inverted], size: .main)
}
