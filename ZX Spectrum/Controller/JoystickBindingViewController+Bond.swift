//
//  Created by Tomaz Kragelj on 7.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

extension JoystickBindingViewController {
	
	/**
	Bond for managing keys table view.
	*/
	final class Bond: NSObject, TableViewBond {
		
		typealias DataSource = Observable2DArray<String, KeyCode>
		typealias SectionType = Observable2DArraySection<String, KeyCode>
		
		// MARK: - Helper functions
		
		/**
		Prepares the array of sections.
		
		@param selected Array of selected key codes.
		*/
		func fetch(selected: [KeyCode]?) -> DataSource {
			let allKeys = KeyCode.all
			let selectedKeys = allKeys.filter { selected?.contains($0) ?? false }
			let availableKeys = allKeys.filter { !selectedKeys.contains($0) }
			
			let result = MutableObservable2DArray<String, KeyCode>()
			
			if selectedKeys.count > 0 {
				result.appendSection(SectionType(metadata: NSLocalizedString("Selected"), items: selectedKeys))
			}
			if availableKeys.count > 0 {
				result.appendSection(SectionType(metadata: NSLocalizedString("Available"), items: availableKeys))
			}
			
			return result
		}

		// MARK: - TableViewBond
		
		func titleForHeader(in section: Int, dataSource: DataSource) -> String? {
			let section = dataSource[section]
			return section.metadata
		}
		
		func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: DataSource) -> UITableViewCell {
			let object = dataSource[indexPath]
			
			gdebug("Dequeuing cell at \(indexPath) for \(object)")
			let result = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath) as! JoystickBindingKeyTableViewCell
			
			result.configure(object: object)
			
			return result
		}
	}
}

// MARK: - Cell

final class JoystickBindingKeyTableViewCell: UITableViewCell, Configurable {
	typealias Data = KeyCode
	
	@IBOutlet fileprivate weak var label: UILabel!
	
	func configure(object: Data) {
		label.text = object.description
	}
}
