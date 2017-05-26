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
	The input state that is currently active.
	*/
	static let inputState = Property<InputState>(.none)
	
	/**
	Currently selected machine.
	*/
	static let selectedMachine = Property<String>("")
	
	// MARK: - Initialization & disposal
	
	static func initialize() {
		setupPlaybackSignals()
	}
}

// MARK: - Inserted file

extension Defaults {
	
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

// MARK: - Playback

extension Defaults {
	
	/**
	Indicates whetehr tape is currently playing or not. Only used for manual mode.
	*/
	static let isTapePlaying = Property<Bool>(false)

	/**
	Current tape block.
	*/
	static let tapePlaybackBlock = Property<Int>(0)
	
	/**
	Current block completion ratio (0..1).
	*/
	static let tapePlaybackBlockCompletionRatio = Property<CGFloat>(0)
	
	/**
	Wires up playback signals to underlying systems.
	
	This should be called once early on in the lifetime of the application.
	*/
	fileprivate static func setupPlaybackSignals() {
		let controller = FuseController.sharedInstance()
		
		controller.statusBarDidUpdate = { type, status in
			if type == UI_STATUSBAR_ITEM_TAPE {
				isTapePlaying.value = status == UI_STATUSBAR_STATE_ACTIVE
			}
		}
		
		controller.tapeBrowserDidUpdate = { status, block in
			switch status {
			case UI_TAPE_BROWSER_NEW_TAPE:
				gdebug("New tape inserted")
				tapePlaybackBlock.value = 0
				
			case UI_TAPE_BROWSER_SELECT_BLOCK:
				gdebug("Block selected")
				tapePlaybackBlock.value = Int(tape_get_current_block())
				
			default:
				break
			}
		}
		
		controller.tapeBlockStateDidChange = { completionRatio in
			tapePlaybackBlockCompletionRatio.value = CGFloat(completionRatio)
		}
	}
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
