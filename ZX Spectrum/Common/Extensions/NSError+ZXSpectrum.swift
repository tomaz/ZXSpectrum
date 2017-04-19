//
//  Created by Tomaz Kragelj on 19.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension NSError {
	
	/**
	File(s) deletion failed error.
	*/
	static func delete(paths: [String]) -> NSError {
		let description = paths.count == 1 ?
			NSLocalizedString("Failed Deleting File") :
			NSLocalizedString("Failed Deleting Files")
		
		
		let first = paths.count == 1 ?
			NSLocalizedString("Remaining file:") :
			NSLocalizedString("Remaining files:")
		
		let last = paths.count == 1 ?
			NSLocalizedString("You can delete it in upload website on your computer.") :
			NSLocalizedString("You can delete them in upload website on your computer.")
		
		let reason = String(paragraphs: first, String(lines: paths), last)
		
		return error(code: -1000, description: description, reason: reason)
	}
}

extension NSError {

	/**
	Prepares the error with teh given data.
	*/
	fileprivate static func error(code: Int, description: String, reason: String? = nil, additionalInfo: [ String: Any ]? = nil) -> NSError {
		var userInfo: [String: Any] = [ NSLocalizedDescriptionKey: description ]
		
		if let reason = reason {
			userInfo[NSLocalizedFailureReasonErrorKey] = reason
		}
		
		if let additionalInfo = additionalInfo {
			for (key, value) in additionalInfo {
				userInfo[key] = value
			}
		}
		
		return NSError(domain: "com.gentlebytes.ZXSpectrum", code: code, userInfo: userInfo)
	}
}

// MARK: - Error presentation

extension UIViewController {
	
	/**
	Presents the error and calls completion block when user selects options. Callback provides single parameter: false if user dismisses the alert, true otherwise.
	*/
	override func present(error: NSError, completionHandler: ((Bool) -> Void)? = nil) {
		var components = [String]()
		
		if let reason = error.localizedFailureReason {
			components.append(reason)
		}
		
		if let suggestion = error.localizedRecoverySuggestion {
			components.append(suggestion)
		}
		
		let title = error.localizedDescription
		let message = components.joined(separator: "\n\n")
		
		let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
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
		
		present(controller, animated: true, completion: nil)
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
