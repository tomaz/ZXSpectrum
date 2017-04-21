//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

extension UserDefaults {
	
	/// If true, we should show joystick for input method, otherwise keyboard.
	var isInputJoystick: Bool {
		get { return bool(forKey: "IsInputJoystick") }
		set { set(newValue, forKey: "IsInputJoystick"); isInputJoystickSubject.next(newValue) }
	}
}

// MARK: - Signals

extension UserDefaults {

	/// Subject that sends event when `isInputJoystick` value changes.
	fileprivate var isInputJoystickSubject: PublishSubject<Bool, NoError> {
		if let existing = objc_getAssociatedObject(self, &AssociatedKeys.IsInputJoystickSubject) as? PublishSubject<Bool, NoError> {
			return existing
		} else {
			let result = PublishSubject<Bool, NoError>()
			objc_setAssociatedObject(self, &AssociatedKeys.IsInputJoystickSubject, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return result
		}
	}
	
	private struct AssociatedKeys {
		static var IsInputJoystickSubject = "IsInputJoystickSubject"
	}
}

extension ReactiveExtensions where Base: UserDefaults {
	
	/// Signals that sends events when `isInputJoystick` value changes.
	var isInputJoystickSignal: SafeSignal<Bool> {
		return base.isInputJoystickSubject.toSignal()
	}
}
