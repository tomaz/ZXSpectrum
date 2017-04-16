//
//  Created by Tomaz Kragelj on 26.03.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class EmulatorViewController: UIViewController {
	
	@IBOutlet fileprivate weak var spectrumView: SpectrumScreenView!
	@IBOutlet fileprivate weak var controlsContainerView: UIView!
	@IBOutlet fileprivate weak var keyboardPlaceholderView: UIView!
	
	@IBOutlet fileprivate weak var tapeButton: UIButton!
	@IBOutlet fileprivate weak var keyboardButton: UIButton!
	
	// MARK: - Data
	
	fileprivate var emulator: Emulator!
	fileprivate let viewWillHideBag = DisposeBag()
	
	// MARK: - Overriden functions

	override func viewDidLoad() {
		super.viewDidLoad()
		
		emulator = Emulator()!
		settings_defaults(&settings_current);
		
		setupTapeButtonTapSignal()
		setupKeyboardButtonTapSignal()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		spectrumView.hookToFuse()
		fuse_init(0, nil);
		
		setupKeyboardWillShowNotificationSignal()
		setupKeyboardWillHideNotificaitonSignal()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		fuse_end()
		spectrumView.unhookFromFuse()
		
		// Dispose all observations that should only happen while view is visible.
		viewWillHideBag.dispose()
	}
}

// MARK: - Signal handling

extension EmulatorViewController {
	
	fileprivate func setupTapeButtonTapSignal() {
		tapeButton.reactive.tap.observe { event in
			
		}.dispose(in: reactive.bag)
	}
	
	fileprivate func setupKeyboardButtonTapSignal() {
		keyboardButton.reactive.tap.observe { _ in
			if self.spectrumView.isFirstResponder {
				self.spectrumView.resignFirstResponder()
			} else {
				self.spectrumView.becomeFirstResponder()
			}
		}.dispose(in: reactive.bag)
	}
	
	fileprivate func setupKeyboardWillShowNotificationSignal() {
		NotificationCenter.default.reactive.notification(name: Notification.Name.UIKeyboardWillShow)
			.map { $0.userInfo }
			.ignoreNil()
			.observeNext { info in
				let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
				
				UIView.animate(withDuration: duration) {
					self.keyboardPlaceholderView.isHidden = false
				}
			}.dispose(in: viewWillHideBag)
		
	}
	
	fileprivate func setupKeyboardWillHideNotificaitonSignal() {
		NotificationCenter.default.reactive.notification(name: Notification.Name.UIKeyboardWillHide)
			.map { $0.userInfo }
			.ignoreNil()
			.observeNext { info in
				let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
				
				UIView.animate(withDuration: duration) {
					self.keyboardPlaceholderView.isHidden = true
				}
			}.dispose(in: viewWillHideBag)
	}
}
