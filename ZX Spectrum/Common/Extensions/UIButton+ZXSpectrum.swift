//
//  Created by Tomaz Kragelj on 19.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension UIButton {

	/**
	Sets image only button with the given image.
	*/
	var image: UIImage? {
		get {
			return image(for: .normal)
		}
		set {
			setTitle(nil, for: .normal)
			setImage(newValue, for: .normal)
		}
	}
}
