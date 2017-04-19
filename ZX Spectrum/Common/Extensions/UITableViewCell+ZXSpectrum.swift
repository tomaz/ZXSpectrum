//
//  Created by Tomaz Kragelj on 19.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension UITableViewCell {

	/**
	Returns parent table view or nil if cell is not added to table view yet.
	*/
	var tableView: UITableView? {
		var result: UIView? = self
		while result != nil && !(result is UITableView) {
			result = result?.superview
		}
		return result as? UITableView
	}
}
