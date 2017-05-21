//
//  Created by Tomaz Kragelj on 20.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

extension TapeBlocksViewController {
	
	/**
	Bond for managing tape blocks table view.
	*/
	final class Bond: NSObject, TableViewBond {

		typealias DataSource = ObservableArray<SpectrumFileBlock>
		
		// MARK: - Fetching
		
		/**
		Prepares the array of all blocks from given info and returns it.
		*/
		func fetch(info: SpectrumFileInfo?) -> [SpectrumFileBlock] {
			return info?.blocks ?? []
		}

		// MARK: - TableViewBond

		func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: DataSource) -> UITableViewCell {
			let object = dataSource[indexPath.row]
			let data = (indexPath.row, object)
			
			gdebug("Dequeuing cell at \(indexPath) for \(object)")
			let result = tableView.dequeueReusableCell(withIdentifier: "BlockCell", for: indexPath) as! TapeBlockTableViewCell
			
			result.configure(object: data)
			
			return result
		}
	}
}
