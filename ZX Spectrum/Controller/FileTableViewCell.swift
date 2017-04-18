//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell, Configurable {
	
	@IBOutlet fileprivate weak var nameLabel: UILabel!
	@IBOutlet fileprivate weak var deleteButton: UIButton!
	@IBOutlet fileprivate weak var actionsContainerView: UIView!
	
	func configure(object: FileObject) {
		gdebug("Configuring with \(object)")
		nameLabel.text = object.filename
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		deleteButton.setTitle(nil, for: .normal)
		deleteButton.setImage(IconsStyleKit.imageOfIconTrash, for: .normal)
		
		actionsContainerView.isHidden = true
		actionsContainerView.alpha = 0
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

	private var tableView: UITableView? {
		var result: UIView? = self
		while result != nil && !(result is UITableView) {
			result = result?.superview
		}
		return result as? UITableView
	}
}
