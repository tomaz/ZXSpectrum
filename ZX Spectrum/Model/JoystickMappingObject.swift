//
//  Created by Tomaz Kragelj on 7.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation
import CoreData

final class JoystickMappingObject: NSManagedObject {
	
	/// Mapping for joystick up or nil if none.
	@NSManaged fileprivate var up: NSNumber?
	
	/// Mapping for joystick down or nil if none.
	@NSManaged fileprivate var down: NSNumber?
	
	/// Mapping for joystick left or nil if none.
	@NSManaged fileprivate var left: NSNumber?
	
	/// Mapping for joystick right or nil if none.
	@NSManaged fileprivate var right: NSNumber?
	
	/// Mapping for joystick button 1 or nil if none.
	@NSManaged fileprivate var button1: NSNumber?
	
	/// Mapping for joystick button 1 or nil if none.
	@NSManaged fileprivate var button2: NSNumber?
	
	/// Mapping for joystick button 1 or nil if none.
	@NSManaged fileprivate var button3: NSNumber?
	
	/// File this mapping is associated with.
	@NSManaged var file: FileObject!
}

// MARK: - Derived properties

extension JoystickMappingObject {
	
	/// Up key codes or nil if not assigned.
	var upKeys: [KeyCode]? {
		get { return getKeyCodes(from: up) }
		set { up = set(keyCodes: newValue) }
	}
	
	/// Down key codes or nil if not assigned.
	var downKeys: [KeyCode]? {
		get { return getKeyCodes(from: down) }
		set { down = set(keyCodes: newValue) }
	}
	
	/// Left key codes or nil if not assigned.
	var leftKeys: [KeyCode]? {
		get { return getKeyCodes(from: left) }
		set { left = set(keyCodes: newValue) }
	}
	
	/// Right key codes or nil if not assigned.
	var rightKeys: [KeyCode]? {
		get { return getKeyCodes(from: right) }
		set { right = set(keyCodes: newValue) }
	}
	
	/// Mapping 1 key codes or nil if not assigned.
	var button1Keys: [KeyCode]? {
		get { return getKeyCodes(from: button1) }
		set { button1 = set(keyCodes: newValue) }
	}
	
	/// Mapping 2 key codes or nil if not assigned.
	var button2Keys: [KeyCode]? {
		get { return getKeyCodes(from: button2) }
		set { button2 = set(keyCodes: newValue) }
	}
	
	/// Mapping 3 key codes or nil if not assigned.
	var button3Keys: [KeyCode]? {
		get { return getKeyCodes(from: button3) }
		set { button3 = set(keyCodes: newValue) }
	}
	
	/// Determines whether at least one button is assigned (false) or not (true).
	var isEmpty: Bool {
		if getValue(from: up) > 0 {
			return false
		}
		
		if getValue(from: down) > 0 {
			return false
		}
		
		if getValue(from: left) > 0 {
			return false
		}
		
		if getValue(from: right) > 0 {
			return false
		}
		
		if getValue(from: button1) > 0 {
			return false
		}
		
		if getValue(from: button2) > 0 {
			return false
		}
		
		if getValue(from: button3) > 0 {
			return false
		}
		
		return true
	}
	
	/**
	Returns array of keys mapped to given button.
	*/
	func keys(for mapping: Mapping) -> [KeyCode]? {
		switch mapping {
		case .up: return upKeys
		case .down: return downKeys
		case .left: return leftKeys
		case .right: return rightKeys
		case .button1: return button1Keys
		case .button2: return button2Keys
		case .button3: return button3Keys
		}
	}
	
	/**
	Sets the array of keys mapped for the given button.
	*/
	func set(keys: [KeyCode]?, for mapping: Mapping) {
		switch mapping {
		case .up: upKeys = keys
		case .down: downKeys = keys
		case .left: leftKeys = keys
		case .right: rightKeys = keys
		case .button1: button1Keys = keys
		case .button2: button2Keys = keys
		case .button3: button3Keys = keys
		}
	}
	
	/**
	Adds the given code to the array of mappings.
	*/
	func add(code: KeyCode, for mapping: Mapping) {
	}
	
	private func getKeyCodes(from number: NSNumber?) -> [KeyCode]? {
		if let number = number {
			var result = [KeyCode]()
			var value = number.uint64Value

			for _ in 0..<4 {
				let code = value & 0xFF
				
				if code > 0 {
					result.append(KeyCode(rawValue: Int(code))!)
				}
				
				value >>= 8
			}
			
			if result.count > 0 {
				return result
			}
		}
		return nil
	}
	
	private func set(keyCodes: [KeyCode]?) -> NSNumber? {
		if let codes = keyCodes, codes.count > 0 {
			assert(codes.count <= 4)
			
			var value: UInt64 = 0

			for code in codes.reversed() {
				value <<= 8
				value |= UInt64(code.rawValue & 0xFF)
			}
			
			if value > 0 {
				return NSNumber(value: value)
			}
		}
		return nil
	}
	
	private func getValue(from number: NSNumber?) -> UInt64 {
		return number?.uint64Value ?? 0
	}
}

// MARK: - Managed & Core Data helpers

extension JoystickMappingObject: Managed {
	
	// Nothing really needed here for now, but we want to use this class the same as all other managed objects
}

// MARK: - Declarations

extension JoystickMappingObject {
	
	enum Mapping: CustomStringConvertible {
		case up
		case down
		case left
		case right
		case button1
		case button2
		case button3
		
		var description: String {
			switch self {
			case .up: return NSLocalizedString("Up")
			case .down: return NSLocalizedString("Down")
			case .left: return NSLocalizedString("Left")
			case .right: return NSLocalizedString("Right")
			case .button1: return NSLocalizedString("Button 1")
			case .button2: return NSLocalizedString("Button 2")
			case .button3: return NSLocalizedString("Button 3")
			}
		}
	}
}

// MARK: - Constants

extension JoystickMappingObject {

	/// Maximum number of keys per single mapping.
	static let maximumKeysPerMapping = 4
}
