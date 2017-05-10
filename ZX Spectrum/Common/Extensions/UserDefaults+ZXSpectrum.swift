//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

extension UserDefaults {
	
	/// If true, screen smoothing is enabled, otherwise not.
	var isScreenSmoothingActive: Bool {
		get { return bool(forKey: "IsScreenSmoothingActive") }
		set { set(newValue, forKey: "IsScreenSmoothingActive"); isScreenSmoothingActiveSubject.next(newValue)  }
	}
	
	/// Joystick sensitivity ratio.
	var joystickSensitivityRatio: Float {
		get { return float(forKey: "JoystickSensitivityRatio") }
		set { set(newValue, forKey: "JoystickSensitivityRatio"); joystickSensitivityRatioSubject.next(newValue) }
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
