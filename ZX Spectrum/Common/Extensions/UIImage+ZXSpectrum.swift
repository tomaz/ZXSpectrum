//
//  Created by Tomaz Kragelj on 14.09.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension UIImage {
	
	/**
	Returnes a new image using the given tint color.
	*/
	func tinted(_ color: UIColor) -> UIImage {
		var image = self.withRenderingMode(.alwaysTemplate)
		
		UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
		
		color.set()
		image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
		image = UIGraphicsGetImageFromCurrentImageContext()!
		
		UIGraphicsEndImageContext()
		
		return image
	}
}
