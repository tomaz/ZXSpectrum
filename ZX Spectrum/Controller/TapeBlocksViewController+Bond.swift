//
//  Created by Tomaz Kragelj on 20.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import SwiftRichString
import ReactiveKit
import Bond

extension TapeBlocksViewController {
	
	/**
	Bond for managing tape blocks table view.
	*/
	final class Bond: NSObject, TableViewBond {

		typealias DataSource = ObservableArray<Item>
		
		// MARK: - Fetching
		
		/**
		Prepares the array of all blocks from given info and returns it.
		*/
		func fetch(info: SpectrumFileInfo?) -> [Item] {
			var result = [Item]()
			
			if let info = info, !info.blocks.isEmpty {
				result.append(contentsOf: info.blocks.map { Item(block: $0) })
			}
			
			if let message = playbackMessage() {
				result.append(Item(message: message))
			}
			
			return result
		}
		
		private func playbackMessage() -> NSAttributedString? {
			// Tape is not inserted, show appropriate message. Note: this should never appear but let's be safe...
			if Defaults.currentFile.value == nil {
				return NSLocalizedString("Please insert tape").set(style: Bond.messageLightStyle)
			}
			
			// If tape is playing, show appropriate message.
			if Defaults.isTapePlaying.value {
				return NSLocalizedString("Playing, reset to cancel").set(style: Bond.messageLightStyle)
			}
			
			// Tape is not playing, inform user how they can start playback.
			switch SpectrumController().selectedMachineType {
			case LIBSPECTRUM_MACHINE_16: fallthrough
			case LIBSPECTRUM_MACHINE_48: fallthrough
			case LIBSPECTRUM_MACHINE_UNKNOWN:
				return Styles.text(from: NSLocalizedString("<n>Type `</n><em>LOAD \"\"</em><n>` and press </n><em>ENTER</em>"), styles: Bond.styles)
			default:
				return Styles.text(from: NSLocalizedString("<n>Select `</n><em>Tape Loader</em><n>` option and press </n><em>ENTER</em>"), styles: Bond.styles)
			}
		}
		
		private static let messageLightStyle = Styles.style(name: "n", appearance: [ .light, .inverted ], size: .info)
		private static let messageEmphasizedStyle = Styles.style(name: "em", appearance: [ .emphasized, .inverted ], size: .info)
		private static let styles: [Style] = [ messageLightStyle, messageEmphasizedStyle ]
		
		// MARK: - TableViewBond

		func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: DataSource) -> UITableViewCell {
			let object = dataSource[indexPath.row]
			
			gdebug("Dequeuing cell at \(indexPath) for \(object)")
			if let block = object.block {
				let result = tableView.dequeueReusableCell(withIdentifier: "BlockCell", for: indexPath) as! TapeBlockTableViewCell
				let data = (indexPath.row, block)
				result.configure(object: data)
				return result
			} else if let message = object.message {
				let result = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! TapeMessageTableViewCell
				result.configure(object: message)
				return result
			}
			
			fatalError("Either block or message needs to be assigned to item!")
		}
	}
	
	final class Item: Equatable, CustomStringConvertible {
		let block: SpectrumFileBlock?
		let message: NSAttributedString?
		
		init(block: SpectrumFileBlock) {
			self.block = block
			self.message = nil
		}
	
		init(message: NSAttributedString) {
			self.block = nil
			self.message = message
		}
		
		var description: String {
			if let block = block {
				return block.description
			} else if let message = message {
				return message.string
			} else {
				fatalError("Either block or message needs to be assigned!")
			}
		}
	}
}

func == (lhs: TapeBlocksViewController.Item, rhs: TapeBlocksViewController.Item) -> Bool {
	if let lb = lhs.block, let rb = lhs.block {
		// If both items represent blocks, compare blocks for equality.
		return lb == rb
	} else if let lm = lhs.message, let rm = rhs.message {
		// If both items represent message, compare message for equality.
		return lm.string == rm.string
	} else {
		// Otherwise assume blocks are not equal.
		return false
	}
}
