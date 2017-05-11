//
//  Created by Tomaz Kragelj on 11.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

extension ReactiveExtensions where Base: UITableView {

	/// Produces event every time table view cell becomes deselected.
	var deselectedRow: SafeSignal<IndexPath> {
		return delegate.signal(for: #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:))) { (subject: PublishSubject<IndexPath, NoError>, _: UITableView, indexPath: NSIndexPath) in
			subject.next(indexPath as IndexPath)
		}
	}

	/// Produces event every time table view cell becomes selected.
	var selectedRow: SafeSignal<IndexPath> {
		return delegate.signal(for: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))) { (subject: PublishSubject<IndexPath, NoError>, _: UITableView, indexPath: NSIndexPath) in
			subject.next(indexPath as IndexPath)
		}
	}
}
