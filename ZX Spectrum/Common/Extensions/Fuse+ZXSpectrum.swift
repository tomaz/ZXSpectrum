//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

typealias KeyCode = keyboard_key_name

extension KeyCode: CustomStringConvertible {
	
	public var description: String {
		switch self {
		case KEYBOARD_space: return "␣"
			
		case KEYBOARD_0: return "0"
		case KEYBOARD_1: return "1"
		case KEYBOARD_2: return "2"
		case KEYBOARD_3: return "3"
		case KEYBOARD_4: return "4"
		case KEYBOARD_5: return "5"
		case KEYBOARD_6: return "6"
		case KEYBOARD_7: return "7"
		case KEYBOARD_8: return "8"
		case KEYBOARD_9: return "9"
			
		case KEYBOARD_a: return "A"
		case KEYBOARD_b: return "B"
		case KEYBOARD_c: return "C"
		case KEYBOARD_d: return "D"
		case KEYBOARD_e: return "E"
		case KEYBOARD_f: return "F"
		case KEYBOARD_g: return "G"
		case KEYBOARD_h: return "H"
		case KEYBOARD_i: return "I"
		case KEYBOARD_j: return "J"
		case KEYBOARD_k: return "K"
		case KEYBOARD_l: return "L"
		case KEYBOARD_m: return "M"
		case KEYBOARD_n: return "N"
		case KEYBOARD_o: return "O"
		case KEYBOARD_p: return "P"
		case KEYBOARD_q: return "Q"
		case KEYBOARD_r: return "R"
		case KEYBOARD_s: return "S"
		case KEYBOARD_t: return "T"
		case KEYBOARD_u: return "U"
		case KEYBOARD_v: return "V"
		case KEYBOARD_w: return "W"
		case KEYBOARD_x: return "X"
		case KEYBOARD_y: return "Y"
		case KEYBOARD_z: return "Z"
			
		case KEYBOARD_Enter: return "ENTER"
		case KEYBOARD_Caps: return "CS"
		case KEYBOARD_Symbol: return "SS"
			
		default: return ""
		}
	}
}

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
