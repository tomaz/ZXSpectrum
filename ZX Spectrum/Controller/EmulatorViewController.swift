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
	@IBOutlet fileprivate weak var spectrumInputView: InputView!
	
	@IBOutlet fileprivate weak var settingsButton: UIButton!
	@IBOutlet fileprivate weak var resetButton: UIButton!
	@IBOutlet fileprivate weak var filesButton: UIButton!
	@IBOutlet fileprivate weak var tapeButton: UIButton!
	@IBOutlet fileprivate weak var joystickButton: UIButton!
	@IBOutlet fileprivate weak var keyboardButton: UIButton!
	
	// MARK: - Data
	
	fileprivate var persistentContainer: NSPersistentContainer!
	
	fileprivate var emulator: Emulator!
	fileprivate let viewWillHideBag = DisposeBag()
	
	// MARK: - Overriden functions

	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		inject(toView: spectrumInputView)
		
		gdebug("Setting up emulator")
		setupEmulator()
		
		gdebug("Setting up view")
		settingsButton.image = IconsStyleKit.imageOfIconGear
		resetButton.image = IconsStyleKit.imageOfIconReset
		filesButton.image = IconsStyleKit.imageOfIconTape
		updateTapeButtonIcon(animated: false)
		updateJoystickButtonIcon(animated: false)
		updateKeyboardButtonIcon(animated: false)

		setupEmulationStartedSignal()
		setupCurrentObjectSignal()
		setupResetButtonTapSignal()
		setupTapeButtonTapSignal()
		setupJoystickButtonTapSignal()
		setupKeyboardButtonTapSignal()
		setupInputStateSettingSignal()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		gverbose("Appearing")
		
		super.viewWillAppear(animated)
		
		gdebug("Preparing for appearance")
		teardownTapOnBackgroundInteraction()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		gverbose("Dissapearing")
		
		super.viewWillDisappear(animated)
		
		gdebug("Preparing for dissapearance")
		viewWillHideBag.dispose()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		Defaults.isEmulationStarted.value = false
		setupTapOnBackgroundInteraction()
		inject(toController: segue.destination)
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIDevice.iPhone ? .portrait : [.portrait, .landscape]
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
		if let controller = segue.source as? SettingsViewController {
			controller.updateSettings()
			updateTapeButtonVisibility()
		}
		Defaults.isEmulationStarted.value = true
	}
	
	fileprivate func updateTapeButtonIcon(animated: Bool = false) {
		let image = Defaults.inputState.value == .tape ? IconsStyleKit.imageOfIconTapeHide : IconsStyleKit.imageOfIconTapeShow
		tapeButton.update(image: image, animated: animated)
	}
	
	fileprivate func updateJoystickButtonIcon(animated: Bool = false) {
		let image = Defaults.inputState.value == .joystick ? IconsStyleKit.imageOfIconJoystickHide : IconsStyleKit.imageOfIconJoystickShow
		joystickButton.update(image: image, animated: animated)
	}
	
	fileprivate func updateKeyboardButtonIcon(animated: Bool = false) {
		let image = Defaults.inputState.value == .keyboard ? IconsStyleKit.imageOfIconKeyboardHide : IconsStyleKit.imageOfIconKeyboardShow
		keyboardButton.update(image: image, animated: animated)
	}
	
	fileprivate func updateTapeButtonVisibility() {
		UIView.animate(withDuration: 0.2) {
			let isAutoPlayEnabled = settings_current.auto_load == 1
			let isTapeMissing = Defaults.currentFile.value == nil
			self.tapeButton.isHidden = isAutoPlayEnabled || isTapeMissing
		}
	}
}

// MARK: - Helper functions

extension EmulatorViewController {
	
	fileprivate func setupEmulator() {
		emulator = Emulator()!
		
		// Read user defaults.
		settings_defaults(&settings_current)
		read_config_file(&settings_current)

		// Hook spectrum view to fuse.
		spectrumView.hookToFuse()
		
		// Initialize fuse.
		fuse_init(0, nil)
		
		// Prepare initial computer.
		let spectrum = SpectrumController()
		if let selected = spectrum.selectedMachine {
			Defaults.selectedMachine.value = spectrum.identifier(for: selected)
		}
	}
}

// MARK: - Signals handling

extension EmulatorViewController {
	
	fileprivate func setupEmulationStartedSignal() {
		// Only handle the event if value is different from current one.
		Defaults.isEmulationStarted.skip(first: 1).distinct().bind(to: self) { me, value in
			gverbose("Updating emulation status")
			if value {
				me.emulator.unpause()
			} else {
				me.emulator.pause()
			}
		}
	}
	
	fileprivate func setupCurrentObjectSignal() {
		Defaults.currentFile.bind(to: self) { me, _ in
			gverbose("Updating views due to current object change")
			me.updateTapeButtonVisibility()
		}
	}
	
	fileprivate func setupResetButtonTapSignal() {
		resetButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Resetting emulator")
			me.emulator.reset()
			me.emulator.tapeRewind()
		}
	}
	
	fileprivate func setupTapeButtonTapSignal() {
		tapeButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Toggling tape")
			me.toggleInputState(to: .tape)
		}
	}
	
	fileprivate func setupJoystickButtonTapSignal() {
		joystickButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Toggling joystick")
			me.toggleInputState(to: .joystick)
		}
	}
	
	fileprivate func setupKeyboardButtonTapSignal() {
		keyboardButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Toggling keyboard")
			me.toggleInputState(to: .keyboard)
		}
		
		keyboardButton.addGestureRecognizer(UILongPressGestureRecognizer { recognizer in
			if recognizer.state == .began {
				ginfo("Showing keyboard selector")
				self.spectrumInputView.selectKeyboardType()
			}
		})
	}
	
	fileprivate func setupInputStateSettingSignal() {
		// When input method changes, update the icons.
		Defaults.inputState.bind(to: self) { me, value in
			gverbose("Input state changed to \(value), updating icons")
			me.updateTapeButtonIcon()
			me.updateJoystickButtonIcon()
			me.updateKeyboardButtonIcon()
		}
	}
	
	private func toggleInputState(to state: InputState) {
		let shouldCloseInput = state == Defaults.inputState.value
		let newState = shouldCloseInput ? .none : state
		
		// If we change to current state, then close input view.
		spectrumInputView.toggle(visible: !shouldCloseInput)
		
		// Update current input state which will trigger observations where we update UI.
		Defaults.inputState.value = newState
	}
}
