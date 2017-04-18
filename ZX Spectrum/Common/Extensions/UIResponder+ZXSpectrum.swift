//
//  Created by Tomaz Kragelj on 18.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension UIResponder {
	
	/// Presents the error with recover attempter (if any) and calls completion block when user selects options.
	func present(error: NSError, completionHandler: ((Bool) -> Void)? = nil) {
		let controller = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: .alert)
		
		if let recoveryAttempter = error.recoveryAttempter as? RecoveryAttempter, let options = error.localizedRecoveryOptions {
			for (index, option) in options.enumerated() {
				controller.addAction(UIAlertAction(title: option, style: .default) { action in
					let recovered = recoveryAttempter.attemptRecovery(error: error, optionIndex: index)
					completionHandler?(recovered)
				})
			}
		} else {
			controller.addAction(UIAlertAction(title: NSLocalizedString("OK"), style: .default) { action in
				completionHandler?(false)
			})
		}
	}
}

/**
Recovery attempter helper class.
*/
class RecoveryAttempter {
	
	typealias OptionHandler = () -> Bool
	
	private var optionsAndHandlers = [(title: String, handler: OptionHandler)]()
	
	var optiontitles: [String] {
		return optionsAndHandlers.map{ $0.title }
	}
	
	func addOption(_ title: String, handler: @escaping OptionHandler) {
		optionsAndHandlers.append( (title, handler) )
	}
	
	func addCancelOption(title: String? = nil) {
		addOption(title ?? NSLocalizedString("Cancel")) { false }
	}
	
	func attemptRecovery(error: NSError, optionIndex: Int) -> Bool {
		return optionsAndHandlers[optionIndex].handler()
	}
}
