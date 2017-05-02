//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Base keybard view; provides basic functionality for all keyboard views.
*/
class BaseKeyboardView: UIView {
	
	/// Callback for key events. If assigned, all events are sent to the closure, otherwise to fuse.
	var key: ((KeyCode, Bool) -> Void)? = nil
}

// MARK: - Subclass API

extension BaseKeyboardView {
	
	/**
	Sends the event for the given key to fuse or `key` closure.
	*/
	final func send(key: KeyCode, pressed: Bool) {
		if let closure = self.key {
			closure(key, pressed)
		} else {
			if pressed {
				keyboard_press(key)
			} else {
				keyboard_release(key)
			}
		}
	}
}
