//
//  Created by Tomaz Kragelj on 25.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension CGSize {
	
	/**
	Returns scaled size.
	*/
	func scaled(_ ratio: CGFloat) -> CGSize {
		return CGSize(width: width * ratio, height: height * ratio)
	}
}
