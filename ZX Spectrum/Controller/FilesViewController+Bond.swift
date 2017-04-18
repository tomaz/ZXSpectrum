//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import Bond

extension FilesViewController {
	
	/**
	Bond for managing files collection view.
	*/
	final class Bond: TableViewBond {
		
		typealias DataSource = ObservableArray<FileObject>

		func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: DataSource) -> UITableViewCell {
			let object = dataSource[indexPath.item]
			
			gdebug("Dequeuing cell at \(indexPath) for \(object)")
			let result = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileTableViewCell
			result.configure(object: object)
			
			return result
		}
	}
}
