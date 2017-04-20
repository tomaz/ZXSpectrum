//
//  Created by Tomaz Kragelj on 20.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Represents a computer cell.
*/
final class SettingsComputerTableViewCell: UITableViewCell, Configurable {
	
	@IBOutlet fileprivate weak var label: UILabel!
	
	func configure(object: Machine) {
		label.text = object.name
	}
}
