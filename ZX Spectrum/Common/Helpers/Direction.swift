//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

class Direction {
	
	static let ENE = radians(-22.5)
	static let NE = radians(-45)
	static let NNE = radians(-67.5)
	static let N = radians(-90)
	static let NNW = radians(-112.5)
	static let NW = radians(-135)
	static let WNW = radians(-157.5)
	static let W = radians(180)
	static let WSW = radians(157.5)
	static let SW = radians(135)
	static let SSW = radians(112.5)
	static let S = radians(90)
	static let SSE = radians(67.5)
	static let SE = radians(45)
	static let ESE = radians(22.5)
	static let E = radians(0)

	static func radians(_ degrees: CGFloat) -> CGFloat {
		return degrees * CGFloat.pi / 180.0
	}
	
	static func degrees(_ radians: CGFloat) -> CGFloat {
		return radians * 180.0 / CGFloat.pi
	}
}

extension CGFloat {
	var isUp: Bool {
		return self >= Direction.NNW && self < Direction.NNE
	}
	
	var isUpRight: Bool {
		return self >= Direction.NNE && self < Direction.ENE
	}
	
	var isRight: Bool {
		return self >= Direction.ENE && self < Direction.ESE
	}
	
	var isDownRight: Bool {
		return self >= Direction.ESE && self < Direction.SSE
	}
	
	var isDown: Bool {
		return self >= Direction.SSE && self < Direction.SSW
	}
	
	var isDownLeft: Bool {
		return self >= Direction.SSW && self < Direction.WSW
	}
	
	var isLeft: Bool {
		return (self >= Direction.WSW && self <= Direction.W) || (self >= -Direction.W && self < Direction.WNW)
	}
	
	var isUpLeft: Bool {
		return self >= Direction.WNW && self < Direction.NNW
	}
}
