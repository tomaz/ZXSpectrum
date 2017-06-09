//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

typealias KeyboardRenderMode = CGRect.Scaler.Mode

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
	
	/// Keyboard rendering mode.
	var keyboardRenderingMode: KeyboardRenderMode {
		get { return KeyboardRenderMode(rawValue: integer(forKey: Keys.KeyboardRenderingMode)) ?? .fit }
		set { set(newValue.rawValue, forKey: Keys.KeyboardRenderingMode); keyboardRenderingModeSubject.next(newValue) }
	}
	
	/// Files sort option.
	var filesSortOption: FileSortOption {
		get { return FileSortOption(rawValue: integer(forKey: Keys.FilesSortOption)) ?? .name }
		set { set(newValue.rawValue, forKey: Keys.FilesSortOption); filesSortOptionSubject.next(newValue) }
	}
	
	fileprivate struct Keys {
		static var IsScreenSmoothingActive = "IsScreenSmoothingActive"
		static var IsHapticFeedbackEnabled = "IsHapticFeedbackEnabled"
		static var JoystickSensitivityRatio = "JoystickSensitivityRatio"
		static var KeyboardRenderingMode = "KeyboardRenderingMode"
		static var FilesSortOption = "FileSortOption"
	}
}

// MARK: - Factory defaults

extension UserDefaults {
	
	static func establishFactoryDefaults() {
		UserDefaults.standard.register(defaults: [
			Keys.IsScreenSmoothingActive: false,
			Keys.IsHapticFeedbackEnabled: Feedback.isHapticFeedbackSupported,
			Keys.JoystickSensitivityRatio: 0.3,
			Keys.KeyboardRenderingMode: KeyboardRenderMode.default.rawValue,
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
	
	/// Subject that sends event when `joystickSensitivityRatio` value changes.
	fileprivate var keyboardRenderingModeSubject: PublishSubject<KeyboardRenderMode, NoError> {
		if let existing = objc_getAssociatedObject(self, &AssociatedKeys.KeyboardRenderingModeSubject) as? PublishSubject<KeyboardRenderMode, NoError> {
			return existing
		} else {
			let result = PublishSubject<KeyboardRenderMode, NoError>()
			objc_setAssociatedObject(self, &AssociatedKeys.KeyboardRenderingModeSubject, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return result
		}
	}
	
	/// Subject that sends event when `filesSortOption` value changes.
	fileprivate var filesSortOptionSubject: PublishSubject<FileSortOption, NoError> {
		if let existing = objc_getAssociatedObject(self, &AssociatedKeys.FilesSortOptionSubject) as? PublishSubject<FileSortOption, NoError> {
			return existing
		} else {
			let result = PublishSubject<FileSortOption, NoError>()
			objc_setAssociatedObject(self, &AssociatedKeys.FilesSortOptionSubject, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return result
		}
	}
	
	private struct AssociatedKeys {
		static var IsScreenSmoothingActiveSubject: UInt8 = 0
		static var JoystickSensitivityRatioSubject: UInt8 = 0
		static var KeyboardRenderingModeSubject: UInt8 = 0
		static var FilesSortOptionSubject: UInt8 = 0
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
	
	/// Signal that sends events when `keyboardRenderingMode` value changes.
	var keyboardRenderingModeSignal: SafeSignal<KeyboardRenderMode> {
		return base.keyboardRenderingModeSubject.toSignal()
	}
	
	/// Signal that sends events when `filesSortOption` value changes.
	var filesSortOptionSignal: SafeSignal<FileSortOption> {
		return base.filesSortOptionSubject.toSignal()
	}
}

// MARK: - Declarations

/**
File sorting options.
*/
enum FileSortOption: Int, CustomStringConvertible {
	/// Sort by name.
	case name
	
	/// Sort by usage date.
	case usage
	
	/// Return array of all sort options.
	static var all: [FileSortOption] {
		return [ .name, .usage ]
	}
	
	/// Returns localized title of the option.
	var title: String {
		switch self {
		case .name: return NSLocalizedString("Name")
		case .usage: return NSLocalizedString("Usage")
		}
	}
	
	var description: String {
		return title
	}
}
