//
//  Created by Tomaz Kragelj on 28.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Manages tape message cell.
*/
final class TapeMessageTableViewCell: UITableViewCell, Configurable {
	
	@IBOutlet fileprivate weak var messageLabel: UILabel!
	
	// MARK: - Configurable
	
	func configure(object: NSAttributedString) {
		messageLabel.attributedText = object
	}
}
