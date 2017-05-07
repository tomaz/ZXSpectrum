//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

extension joystick_button: CustomStringConvertible {
	
	public var description: String {
		switch self {
		case JOYSTICK_BUTTON_UP: return "UP"
		case JOYSTICK_BUTTON_DOWN: return "DOWN"
		case JOYSTICK_BUTTON_LEFT: return "LEFT"
		case JOYSTICK_BUTTON_RIGHT: return "RIGHT"
		case JOYSTICK_BUTTON_FIRE: return "FIRE"
		default: return ""
		}
	}
}
