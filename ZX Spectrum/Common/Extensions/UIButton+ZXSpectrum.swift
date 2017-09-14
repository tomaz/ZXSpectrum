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
	Title.
	*/
	var title: String? {
		get {
			return title(for: .normal)
		}
		set {
			setTitle(newValue, for: .normal)
		}
	}
	
	/**
	Attributed title.
	*/
	var attributedTitle: NSAttributedString? {
		get {
			return attributedTitle(for: .normal)
		}
		set {
			setAttributedTitle(newValue, for: .normal)
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
	
	/**
	Performs animation of the button from the current image, to given one and after the given amount of seconds animates back to original.
	*/
	func animate(image temporaryImage: UIImage?, for time: Double, completion: (() -> Void)? = nil) {
		let originalImage = image
		let fadeTime = 0.25
		let delay = max(time - 2 * fadeTime, 0.25)

		func animate(from: UIImage?, to: UIImage?, name: String) {
			let animation = CABasicAnimation(keyPath:"contents")
			animation.duration = fadeTime
			animation.fromValue = from?.cgImage
			animation.toValue = to?.cgImage
			animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			animation.isRemovedOnCompletion = true
			imageView?.layer.add(animation, forKey: name)
			setImage(to, for: .normal)
		}
		
		animate(from: originalImage, to: temporaryImage, name: "animateContentsIn")
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			animate(from: temporaryImage, to: originalImage, name: "animateContentsOut")
		}
	}
}
