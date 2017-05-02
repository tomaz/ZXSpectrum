//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class JoystickMappingViewController: UIViewController {
	
	@IBOutlet fileprivate weak var deleteBarButton: UIBarButtonItem!
	@IBOutlet fileprivate weak var zx48KeyboardView: ZX48KeyboardView!
	
	/// Assigned key code handler; called after user presses the key.
	fileprivate var keyCodeHandler: KeyCodeHandler? = nil
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		zx48KeyboardView.key = handle(key:pressed:)
		
		setupDeleteButtonSignals()
	}
}

// MARK: - Dependencies

extension JoystickMappingViewController: KeyCodeConsumer {
	
	func configure(keyCodeHandler: @escaping KeyCodeHandler) {
		gdebug("Configuring with key code handler \(keyCodeHandler)")
		self.keyCodeHandler = keyCodeHandler
	}
}

// MARK: - User interface

extension JoystickMappingViewController {
	
	/**
	Handles the given key press/release
	*/
	fileprivate func handle(key: KeyCode, pressed: Bool) {
		if pressed {
			ginfo("\(key) pressed")
			keyCodeHandler?(key)
		}
	}
	
	fileprivate func setupDeleteButtonSignals() {
		deleteBarButton.reactive.tap.bind(to: self) { _ in
			self.keyCodeHandler?(nil)
		}
	}
}
