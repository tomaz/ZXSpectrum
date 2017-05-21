//
//  Created by Tomaz Kragelj on 20.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import Bond

/**
Manages various settings.
*/
class SettingsViewController: UITableViewController {
	
	@IBOutlet fileprivate weak var computerLabel: UILabel!
	@IBOutlet fileprivate weak var fastloadSwitch: UISwitch!
	@IBOutlet fileprivate weak var autoloadSwitch: UISwitch!

	@IBOutlet fileprivate weak var joystickSensitivitySlider: UISlider!
	
	@IBOutlet fileprivate weak var screenSmoothingSwitch: UISwitch!
	@IBOutlet fileprivate weak var hapticFeedbackSwitch: UISwitch!
	
	// MARK: - Helpers
	
	fileprivate lazy var defaults = UserDefaults.standard
	fileprivate lazy var spectrum = SpectrumController()
	fileprivate lazy var startingMachine: Machine! = nil
	fileprivate lazy var selectedMachine: Machine! = nil
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")

		super.viewDidLoad()

		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		
		gdebug("Setting up data")
		startingMachine = spectrum.selectedMachine
		selectedMachine = startingMachine

		gdebug("Binding data")
		computerLabel.text = spectrum.selectedMachine?.name
		fastloadSwitch.isOn = settings_current.fastload == 1
		autoloadSwitch.isOn = settings_current.auto_load == 1
		joystickSensitivitySlider.value = 1 - defaults.joystickSensitivityRatio
		screenSmoothingSwitch.isOn = defaults.isScreenSmoothingActive
		hapticFeedbackSwitch.isOn = defaults.isHapticFeedbackEnabled
	}
}

// MARK: - User interface

extension SettingsViewController {
	
	/**
	Updates the settings and emulator.
	*/
	func updateSettings() {
		// We intercept done bar button action which happens before unwind segue.
		ginfo("Exiting settings")
		
		// If tape is currently playing, we need to stop it if autoload setting changes.
		var shouldStopTape = autoloadSwitch.isOn != (settings_current.auto_load == 1)
		
		// Update user defaults.
		defaults.joystickSensitivityRatio = 1 - joystickSensitivitySlider.value
		defaults.isScreenSmoothingActive = screenSmoothingSwitch.isOn
		defaults.isHapticFeedbackEnabled = hapticFeedbackSwitch.isOn
		
		// Update fuse based user defaults.
		defaults.set(fastloadSwitch.isOn, forKey: "fastload")
		defaults.set(autoloadSwitch.isOn, forKey: "autoload")
		defaults.set(spectrum.identifier(for: selectedMachine), forKey: "machine")
		
		// Read user defaults into fuse settings.
		read_config_file(&settings_current)
		
		// Change the machine if different one is selected.
		if let selected = selectedMachine, let starting = startingMachine, selected !== starting {
			shouldStopTape = true
			spectrum.selectedMachine = selected
			Defaults.selectedMachine.value = spectrum.identifier(for: selected)
		}
		
		// Stop playback of current tape if needed.
		if shouldStopTape && Defaults.isTapePlaying.value {
			Defaults.isTapePlaying.value = false
		}
		
		display_refresh_all();
	}
	
	@IBAction func unwindToSettingsViewController(segue: UIStoryboardSegue) {
		if let controller = segue.source as? SettingsComputerViewController, let machine = controller.selected {
			selectedMachine = machine
			computerLabel.text = machine.name
		}
	}
}
