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
	
	/**
	If true, emulation should be running, otherwise not.
	*/
	static let isEmulationStarted = Property<Bool>(false)
	
	/**
	Indicates whetehr tape is currently playing or not. Only used for manual mode.
	*/
	static let isTapePlaying = Property<Bool>(false)
	
	/**
	The input state that is currently active.
	*/
	static let inputState = Property<InputState>(.none)
	
	/**
	Currently selected machine.
	*/
	static let selectedMachine = Property<String>("")
	
	/**
	Current file object; this is nil when no file is selected.
	*/
	static let currentFile = Property<FileObject?>(nil)
	
	/**
	File info for `currentFile`.
	
	Note this value always changes with `currentFile`, but before it, so if you need both, you can observe `currentFile` and access both values in the handler. 
	
	Also note this value may be nil even if `currentFile` isn't nil; this there was something wrong reading the info and so isn't available.
	*/
	static let currentFileInfo = Property<SpectrumFileInfo?>(nil)
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
