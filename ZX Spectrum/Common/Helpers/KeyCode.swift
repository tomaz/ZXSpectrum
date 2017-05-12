//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

enum KeyCode: Int {

	case space = 1 // We must start with non zero because 0 is interpretted as no key in `JoystickMappingObject`!
	case brk
	
	case num0
	case num1
	case num2
	case num3
	case num4
	case num5
	case num6
	case num7
	case num8
	case num9
	
	case a
	case b
	case c
	case d
	case e
	case f
	case g
	case h
	case i
	case j
	case k
	case l
	case m
	case n
	case o
	case p
	case q
	case r
	case s
	case t
	case u
	case v
	case w
	case x
	case y
	case z
	
	case period
	case comma
	case semicolon
	case doubleQuote
	
	case enter
	case capsShift
	case symbolShift
	
	case edit
	case delete
	case capsLock
	case trueVideo
	case inverseVideo
	case graphics
	
	case up
	case down
	case left
	case right
}

// MARK: - CustomStringConvertible

extension KeyCode: CustomStringConvertible {
	
	var description: String {
		switch self {
		case .space: return NSLocalizedString("SPACE")
		case .brk: return NSLocalizedString("BREAK")
			
		case .num0: return "0"
		case .num1: return "1"
		case .num2: return "2"
		case .num3: return "3"
		case .num4: return "4"
		case .num5: return "5"
		case .num6: return "6"
		case .num7: return "7"
		case .num8: return "8"
		case .num9: return "9"
			
		case .a: return "A"
		case .b: return "B"
		case .c: return "C"
		case .d: return "D"
		case .e: return "E"
		case .f: return "F"
		case .g: return "G"
		case .h: return "H"
		case .i: return "I"
		case .j: return "J"
		case .k: return "K"
		case .l: return "L"
		case .m: return "M"
		case .n: return "N"
		case .o: return "O"
		case .p: return "P"
		case .q: return "Q"
		case .r: return "R"
		case .s: return "S"
		case .t: return "T"
		case .u: return "U"
		case .v: return "V"
		case .w: return "W"
		case .x: return "X"
		case .y: return "Y"
		case .z: return "Z"
			
		case .period: return ","
		case .comma: return "."
		case .semicolon: return ";"
		case .doubleQuote: return "\""
			
		case .enter: return NSLocalizedString("ENTER")
		case .capsShift: return NSLocalizedString("CAPS SHIFT")
		case .symbolShift: return NSLocalizedString("SYMBOL SHIFT")
			
		case .edit: return NSLocalizedString("EDIT")
		case .delete: return NSLocalizedString("DELETE")
		case .capsLock: return NSLocalizedString("CAPS LOCK")
		case .trueVideo: return NSLocalizedString("TRUE VIDEO")
		case .inverseVideo: return NSLocalizedString("INV. VIDEO")
		case .graphics: return NSLocalizedString("GRAPHICS")
			
		case .up: return "↑"
		case .down: return "↓"
		case .left: return "←"
		case .right: return "→"
		}
	}
}

// MARK: - Derived properties

extension KeyCode {
	
	/// Converts the value to fuse keyboard code(s)
	var fuseKeys: [keyboard_key_name] {
		switch self {
		case .space: return [KEYBOARD_space]
		case .brk: return [KEYBOARD_Caps, KEYBOARD_space]
			
		case .num0: return [KEYBOARD_0]
		case .num1: return [KEYBOARD_1]
		case .num2: return [KEYBOARD_2]
		case .num3: return [KEYBOARD_3]
		case .num4: return [KEYBOARD_4]
		case .num5: return [KEYBOARD_5]
		case .num6: return [KEYBOARD_6]
		case .num7: return [KEYBOARD_7]
		case .num8: return [KEYBOARD_8]
		case .num9: return [KEYBOARD_9]
			
		case .a: return [KEYBOARD_a]
		case .b: return [KEYBOARD_b]
		case .c: return [KEYBOARD_c]
		case .d: return [KEYBOARD_d]
		case .e: return [KEYBOARD_e]
		case .f: return [KEYBOARD_f]
		case .g: return [KEYBOARD_g]
		case .h: return [KEYBOARD_h]
		case .i: return [KEYBOARD_i]
		case .j: return [KEYBOARD_j]
		case .k: return [KEYBOARD_k]
		case .l: return [KEYBOARD_l]
		case .m: return [KEYBOARD_m]
		case .n: return [KEYBOARD_n]
		case .o: return [KEYBOARD_o]
		case .p: return [KEYBOARD_p]
		case .q: return [KEYBOARD_q]
		case .r: return [KEYBOARD_r]
		case .s: return [KEYBOARD_s]
		case .t: return [KEYBOARD_t]
		case .u: return [KEYBOARD_u]
		case .v: return [KEYBOARD_v]
		case .w: return [KEYBOARD_w]
		case .x: return [KEYBOARD_x]
		case .y: return [KEYBOARD_y]
		case .z: return [KEYBOARD_z]
			
		case .period: return [KEYBOARD_Symbol, KEYBOARD_n]
		case .comma: return [KEYBOARD_Symbol, KEYBOARD_m]
		case .semicolon: return [KEYBOARD_Symbol, KEYBOARD_o]
		case .doubleQuote: return [KEYBOARD_Symbol, KEYBOARD_p]
			
		case .enter: return [KEYBOARD_Enter]
		case .capsShift: return [KEYBOARD_Caps]
		case .symbolShift: return [KEYBOARD_Symbol]
			
		case .edit: return [KEYBOARD_Caps, KEYBOARD_1]
		case .delete: return [KEYBOARD_Caps, KEYBOARD_0]
		case .capsLock: return [KEYBOARD_Caps, KEYBOARD_2]
		case .trueVideo: return [KEYBOARD_Caps, KEYBOARD_3]
		case .inverseVideo: return [KEYBOARD_Caps, KEYBOARD_4]
		case .graphics: return [KEYBOARD_Caps, KEYBOARD_9]
			
		case .up: return [KEYBOARD_Caps, KEYBOARD_7]
		case .down: return [KEYBOARD_Caps, KEYBOARD_6]
		case .left: return [KEYBOARD_Caps, KEYBOARD_5]
		case .right: return [KEYBOARD_Caps, KEYBOARD_8]
		}
	}
	
	/// Array of all key codes.
	static let all: [KeyCode] = [
		.num0, .num1, .num2, .num3, .num4, .num5, .num6, .num7, .num8, .num9,
		
		.a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k, .l, .m, .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x, .y, .z,
		
		.up,
		.down,
		.left,
		.right,
		
		.space,
		.brk,
		.enter,
		.delete,
		
		.capsLock,
		.capsShift,
		.symbolShift,
		
		.edit,
		.graphics,
		.trueVideo,
		.inverseVideo,
	]
}

// MARK: - Helper functions

extension KeyCode {
	
	/**
	Injects this key code to fuse either as pressed or released.
	*/
	func inject(pressed: Bool) {
		fuseKeys.forEach { key in
			if pressed {
				keyboard_press(key)
			} else {
				keyboard_release(key)
			}
		}
	}
	
	/**
	Injects the given array of keys to fuse either as pressed or released.
	*/
	static func inject(keys: [KeyCode]?, pressed: Bool) {
		keys?.forEach { $0.inject(pressed: pressed) }
	}
	
	/**
	Returns the description of all keys in the given array.
	*/
	static func description(keys: [KeyCode]?, separator: String = "+") -> String {
		guard let keys = keys else {
			return "..."
		}
		let descriptions = keys.map { $0.description }
		return descriptions.joined(separator: separator)
	}
}
