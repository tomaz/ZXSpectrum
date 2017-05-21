//
//  Created by Tomaz Kragelj on 20.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import Bond

/**
Manages the list of selected tape blocks.
*/
final class TapeBlocksViewController: UITableViewController {
	
	fileprivate var info: SpectrumFileInfo?
	
	fileprivate lazy var blocks = MutableObservableArray<SpectrumFileBlock>([])
	
	// MARK: - Helpers
	
	fileprivate lazy var bond = Bond()

	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension

		gdebug("Binding data")
		blocks.bind(to: tableView, using: bond)

		gdebug("Setting up signals")
		setupCurrentTapeSignal()
		
		fetch(animated: false)
	}
}

// MARK: - Helper functions

extension TapeBlocksViewController {
	
	/**
	Fetches data and updates `blocks` with results.
	*/
	fileprivate func fetch(animated: Bool = true) {
		gdebug("Fetching blocks")
		let newBlocks = bond.fetch(info: info)
		
		gdebug("Updating with \(newBlocks.count) blocks")
		blocks.replace(with: newBlocks, performDiff: animated)
	}
}

// MARK: - Signals handling

extension TapeBlocksViewController {
	
	fileprivate func setupCurrentTapeSignal() {
		Defaults.currentFile.bind(to: self) { me, value in
			gverbose("Current file changed to \(String(describing: value))")
			me.info = Defaults.currentFileInfo.value
			me.fetch()
		}
	}
}
