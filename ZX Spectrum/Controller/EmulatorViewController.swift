//
//  Created by Tomaz Kragelj on 26.03.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import Bond
import ReactiveKit

class EmulatorViewController: UIViewController {
	
	@IBOutlet fileprivate weak var spectrumView: SpectrumScreenView!
	@IBOutlet fileprivate weak var controlsContainerView: UIView!
	@IBOutlet fileprivate weak var keyboardPlaceholderView: UIView!
	
	@IBOutlet fileprivate weak var tapeButton: UIButton!
	@IBOutlet fileprivate weak var keyboardButton: UIButton!
	
	// MARK: - Data
	
	fileprivate var persistentContainer: NSPersistentContainer!
	
	fileprivate var emulator: Emulator!
	fileprivate let viewWillHideBag = DisposeBag()
	
	// MARK: - Overriden functions

	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		gdebug("Setting up emulator")
		emulator = Emulator()!
		settings_defaults(&settings_current);
		
		gdebug("Setting up view")
		setupTapeButtonTapSignal()
		setupKeyboardButtonTapSignal()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		gverbose("Appearing")
		
		super.viewWillAppear(animated)
		
		gdebug("Starting emulator")
		spectrumView.hookToFuse()
		fuse_init(0, nil);
		
		gdebug("Preparing for appearance")
		setupKeyboardWillShowNotificationSignal()
		setupKeyboardWillHideNotificaitonSignal()
		teardownTapOnBackgroundInteraction()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		gverbose("Dissapearing")
		
		super.viewWillDisappear(animated)
		
		gdebug("Stopping emulator")
		fuse_end()
		spectrumView.unhookFromFuse()
		
		gdebug("Preparing for dissapearance")
		viewWillHideBag.dispose()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		setupTapOnBackgroundInteraction()
		inject(toController: segue.destination)
	}
}

// MARK: - Dependencies

extension EmulatorViewController: PersistentContainerProvider {
	
	func providePersistentContainer() -> NSPersistentContainer {
		gdebug("Providing \(persistentContainer)")
		return persistentContainer
	}
}

extension EmulatorViewController: PersistentContainerConsumer {
	
	func configure(persistentContainer: NSPersistentContainer) {
		gdebug("Configuring with \(persistentContainer)")
		self.persistentContainer = persistentContainer
	}
}

// MARK: - User interface

extension EmulatorViewController {
	
	@IBAction func unwindToEmulatorViewController(segue: UIStoryboardSegue) {
		// Nothing to do here, but the function is needed for unwinding segues.
	}
}

// MARK: - Signals handling

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
