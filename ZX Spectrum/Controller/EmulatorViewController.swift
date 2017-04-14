//
//  Created by Tomaz Kragelj on 26.03.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class EmulatorViewController: UIViewController {
	
	@IBOutlet fileprivate weak var spectrumView: SpectrumScreenView!
	@IBOutlet fileprivate weak var controlsContainerView: UIView!
	@IBOutlet fileprivate weak var keyboardResizerHeightContraint: NSLayoutConstraint!
	
	// MARK: - Data
	
	private var emulator: Emulator!
	
	// MARK: - Overriden functions

	override func viewDidLoad() {
		super.viewDidLoad()
		
		emulator = Emulator()!
		
		settings_defaults(&settings_current);
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
		
		spectrumView.hookToFuse()
		fuse_init(0, nil);
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
		
		fuse_end()
		spectrumView.unhookFromFuse()
	}
}

// MARK: - Observations

extension EmulatorViewController {
	
	@objc fileprivate func keyboardWillShow(notification: Notification) {
		guard let info = notification.userInfo else {
			return
		}
		
		let size = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
		let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		let curve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue

		UIView.beginAnimations("DisplayingKeyboard", context: nil)
		UIView.setAnimationDuration(duration)
		UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
		
		keyboardResizerHeightContraint.constant = size.height
		
		UIView.commitAnimations()
	}
	
	@objc fileprivate func keyboardWillHide(notification: Notification) {
		guard let info = notification.userInfo else {
			return
		}
		
		let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		let curve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue
		
		UIView.beginAnimations("DismissingKeyboard", context: nil)
		UIView.setAnimationDuration(duration)
		UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
		
		keyboardResizerHeightContraint.constant = 0
		
		UIView.commitAnimations()
	}
}

// MARK: - User interface

extension EmulatorViewController {
	
	@IBAction private func toggleKeyboard() {
		if spectrumView.isFirstResponder {
			spectrumView.resignFirstResponder()
		} else {
			spectrumView.becomeFirstResponder()
		}
	}
}
