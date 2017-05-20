//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation
import CoreData
import ReactiveKit

/**
Various non-persistent defaults.
*/
class Defaults {
	
	/// If true, emulation should be running, otherwise not.
	static let isEmulationStarted = Property<Bool>(false)
	
	/// The input state that is currently active.
	static let inputState = Property<InputState>(.none)
	
	/// Currently selected machine.
	static let selectedMachine = Property<String>("")
	
	/// Current object IS; this is nil when no file is selected.
	static let currentObjectID = Property<NSManagedObjectID?>(nil)
}


/**
Input states.
*/
enum InputState: Int {
	/// No input is active.
	case none
	
	/// Tape commands view is active.
	case tape
	
	/// Joystick view is active.
	case joystick
	
	/// Keyboard view is active.
	case keyboard
}
