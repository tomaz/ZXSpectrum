//
//  Created by Tomaz Kragelj on 19.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

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

extension ReactiveExtensions where Base: UITableView {

	/// Produces event every time table view selection changes.
	var selectedRow: SafeSignal<IndexPath> {
		return delegate.signal(for: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))) { (subject: PublishSubject<IndexPath, NoError>, _: UITableView, indexPath: NSIndexPath) in
			subject.next(indexPath as IndexPath)
		}
	}
}
