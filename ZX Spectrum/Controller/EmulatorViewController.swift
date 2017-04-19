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
	
	@IBOutlet fileprivate weak var settingsButton: UIButton!
	@IBOutlet fileprivate weak var resetButton: UIButton!
	@IBOutlet fileprivate weak var filesButton: UIButton!
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
		settingsButton.image = IconsStyleKit.imageOfIconGear
		resetButton.image = IconsStyleKit.imageOfIconReset
		filesButton.image = IconsStyleKit.imageOfIconTape
		updateKeyboardButtonIcon()
		
		setupResetButtonSignals()
		setupKeyboardButtonSignals()
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

extension EmulatorViewController: PersistentContainerConsumer, PersistentContainerProvider {
	
	func configure(persistentContainer: NSPersistentContainer) {
		gdebug("Configuring with \(persistentContainer)")
		self.persistentContainer = persistentContainer
	}
	
	func providePersistentContainer() -> NSPersistentContainer {
		gdebug("Providing \(persistentContainer)")
		return persistentContainer
	}
}

extension EmulatorViewController: EmulatorProvider {
	
	func provideEmulator() -> Emulator {
		gdebug("Providing \(emulator)")
		return emulator
	}
}

// MARK: - User interface

extension EmulatorViewController {
	
	@IBAction func unwindToEmulatorViewController(segue: UIStoryboardSegue) {
		// Nothing to do here, but the function is needed for unwinding segues.
	}
	
	fileprivate func updateKeyboardButtonIcon(animated: Bool = false) {
		let image = spectrumView.isFirstResponder ? IconsStyleKit.imageOfIconKeyboardHide : IconsStyleKit.imageOfIconKeyboardShow
		
		if animated {
			UIView.animate(withDuration: 0.1, animations: { 
				self.keyboardButton.alpha = 0
			}, completion: { completed in
				self.keyboardButton.image = image
				UIView.animate(withDuration: 0.1) {
					self.keyboardButton.alpha = 1
				}
			})
		} else {
			keyboardButton.image = image
		}
	}
}

// MARK: - Signals handling

extension EmulatorViewController {
	
	fileprivate func setupResetButtonSignals() {
		resetButton.reactive.tap.observe { event in
			ginfo("Resetting emulator")
			self.emulator.reset()
		}.dispose(in: reactive.bag)
	}
	
	fileprivate func setupKeyboardButtonSignals() {
		keyboardButton.reactive.tap.observe { _ in
			ginfo("Toggling keyboard")
			if self.spectrumView.isFirstResponder {
				self.spectrumView.resignFirstResponder()
			} else {
				self.spectrumView.becomeFirstResponder()
			}
			self.updateKeyboardButtonIcon(animated: true)
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
