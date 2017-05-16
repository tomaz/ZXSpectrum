//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

extension UserDefaults {
	
	/// If true, screen smoothing is enabled, otherwise not.
	var isScreenSmoothingActive: Bool {
		get { return bool(forKey: Keys.IsScreenSmoothingActive) }
		set { set(newValue, forKey: Keys.IsScreenSmoothingActive); isScreenSmoothingActiveSubject.next(newValue)  }
	}
	
	/// If true, haptic feedback is enabled, otherwise not.
	var isHapticFeedbackEnabled: Bool {
		get { return bool(forKey: Keys.IsHapticFeedbackEnabled) }
		set { set(newValue, forKey: Keys.IsHapticFeedbackEnabled) }
	}
	
	/// Joystick sensitivity ratio.
	var joystickSensitivityRatio: Float {
		get { return float(forKey: Keys.JoystickSensitivityRatio) }
		set { set(newValue, forKey: Keys.JoystickSensitivityRatio); joystickSensitivityRatioSubject.next(newValue) }
	}
	
	fileprivate struct Keys {
		static var IsScreenSmoothingActive = "IsScreenSmoothingActive"
		static var IsHapticFeedbackEnabled = "IsHapticFeedbackEnabled"
		static var JoystickSensitivityRatio = "JoystickSensitivityRatio"
	}
}

// MARK: - Factory defaults

extension UserDefaults {
	
	static func establishFactoryDefaults() {
		UserDefaults.standard.register(defaults: [
			Keys.IsScreenSmoothingActive: false,
			Keys.IsHapticFeedbackEnabled: Feedback.isHapticFeedbackSupported,
			Keys.JoystickSensitivityRatio: 0.3
		])
	}
}

// MARK: - Signals

extension UserDefaults {
	
	/// Subject that sends event when `isScreenSmoothingActive` value changes.
	fileprivate var isScreenSmoothingActiveSubject: PublishSubject<Bool, NoError> {
		if let existing = objc_getAssociatedObject(self, &AssociatedKeys.IsScreenSmoothingActiveSubject) as? PublishSubject<Bool, NoError> {
			return existing
		} else {
			let result = PublishSubject<Bool, NoError>()
			objc_setAssociatedObject(self, &AssociatedKeys.IsScreenSmoothingActiveSubject, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return result
		}
	}

	/// Subject that sends event when `joystickSensitivityRatio` value changes.
	fileprivate var joystickSensitivityRatioSubject: PublishSubject<Float, NoError> {
		if let existing = objc_getAssociatedObject(self, &AssociatedKeys.JoystickSensitivityRatioSubject) as? PublishSubject<Float, NoError> {
			return existing
		} else {
			let result = PublishSubject<Float, NoError>()
			objc_setAssociatedObject(self, &AssociatedKeys.JoystickSensitivityRatioSubject, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return result
		}
	}
	
	private struct AssociatedKeys {
		static var IsScreenSmoothingActiveSubject = "IsScreenSmoothingActiveSubject"
		static var JoystickSensitivityRatioSubject = "JoystickSensitivityRatioSubject"
	}
}

extension ReactiveExtensions where Base: UserDefaults {
	
	/// Signal that sends events when `isScreenSmoothingActive` value changes.
	var isScreenSmoothingActiveSignal: SafeSignal<Bool> {
		return base.isScreenSmoothingActiveSubject.toSignal()
	}
	
	/// Signal that sends events when `joystickSensitivityRatio` value changes.
	var joystickSensitivityRatioSignal: SafeSignal<Float> {
		return base.joystickSensitivityRatioSubject.toSignal()
	}
}
