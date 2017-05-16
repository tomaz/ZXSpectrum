//
//  Created by Tomaz Kragelj on 16.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation
import AudioToolbox

/**
Manages vibrations.
*/
final class Feedback {
	
	/**
	Produces a vibration.
	*/
	static func produce() {
		guard UserDefaults.standard.isHapticFeedbackEnabled else {
			return
		}
		
		if isHapticFeedbackSupported {
			feedbackGenerator.impactOccurred()
		} else {
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
		}
	}
	
	/// Haptic feedback generator.
	private static let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

	/// Determines whether haptic feedback is supported or not.
	static let isHapticFeedbackSupported: Bool = {
		if let value = UIDevice.current.value(forKey: "_feedbackSupportLevel") as? Int {
			return value == 2
		}
		return false
	}()
}
