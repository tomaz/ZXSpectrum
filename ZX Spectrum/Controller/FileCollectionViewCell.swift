//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class FileCollectionViewCell: UICollectionViewCell, Configurable {
	
	@IBOutlet fileprivate weak var nameLabel: UILabel!
	
	func configure(object: FileObject) {
		gdebug("Configuring with \(object)")
		nameLabel.text = object.url.deletingPathExtension().lastPathComponent
	}
}
