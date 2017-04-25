//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension CGPoint {
	
	/**
	Returns distance to the given point.
	*/
	func distance(to: CGPoint) -> CGFloat {
		let dx = x - to.x
		let dy = y - to.y
		return sqrt((dx * dx) + (dy * dy))
	}
	
	/**
	Returns angle in radians to the given point.
	*/
	func angle(to: CGPoint) -> CGFloat {
		let dx = x - to.x
		let dy = y - to.y
		return atan2(dy, dx)
	}
	
	/**
	Determines if the given point represents "noticable" change to this point.
	
	This is mainly useful to filter out screen redraw only to when it'll be noticable to user.
	*/
	func isNoticableChange(to point: CGPoint) -> Bool {
		if abs(x - point.x) > CGPoint.noticableDifference {
			return true
		}
		if abs(y - point.y) > CGPoint.noticableDifference {
			return true
		}
		return false
	}
	
	/**
	The distance that results in "noticable" movement.
	*/
	static let noticableDifference = CGFloat(5)
}
