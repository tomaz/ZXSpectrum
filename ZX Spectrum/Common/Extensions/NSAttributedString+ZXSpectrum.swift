//
//  Created by Tomaz Kragelj on 15.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
	
	/**
	Appends the given text as new line.
	*/
	func appendLine(_ text: NSAttributedString? = nil) {
		if length > 0 {
			append(NSAttributedString(string: "\n"))
		}
		if let text = text {
			append(text)
		}
	}
}
