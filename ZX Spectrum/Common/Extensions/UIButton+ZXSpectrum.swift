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
	
	/**
	Updates the image optionally animating the transition
	*/
	func update(image: UIImage, animated: Bool, duration: TimeInterval = 0.2) {
		if animated {
			UIView.animate(withDuration: duration / 2.0, animations: {
				self.alpha = 0
			}, completion: { completed in
				self.image = image
				UIView.animate(withDuration: duration / 2.0) {
					self.alpha = 1
				}
			})
		} else {
			self.image = image
		}
	}
}
