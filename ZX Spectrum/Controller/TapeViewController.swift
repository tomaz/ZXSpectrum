//
//  Created by Tomaz Kragelj on 20.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import ReactiveKit
import Bond

/**
Manages tape.
*/
final class TapeViewController: UIViewController {
	
	@IBOutlet fileprivate weak var messageLabel: UILabel!
	
	// MARK: - Initialization & disposal
	
	/**
	Creates and returns new instance.
	*/
	static func instantiate() -> TapeViewController {
		let storyboard = UIViewController.current.storyboard!
		return storyboard.instantiateViewController(withIdentifier: "TapeScene") as! TapeViewController
	}
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		gdebug("Setting up view")
		setupMessage()
		
		gdebug("Setting up signals")
		setupSelectedMachineSignal()
		setupCurrentObjectSignal()
		setupTapePlayingSignal()
	}
}

// MARK: - User interface

extension TapeViewController {
	
	fileprivate func setupMessage() {
		// Tape is not inserted, show appropriate message. Note: this should never appear but let's be safe...
		if Defaults.currentFile.value == nil {
			messageLabel.text = NSLocalizedString("Please insert tape")
			return
		}
		
		// If tape is playing, show appropriate message.
		if Defaults.isTapePlaying.value {
			messageLabel.text = NSLocalizedString("Playing, reset to cancel")
			return
		}
		
		// Tape is not playing, inform user how they can start playback.
		switch SpectrumController().selectedMachineType {
		case LIBSPECTRUM_MACHINE_16: fallthrough
		case LIBSPECTRUM_MACHINE_48: fallthrough
		case LIBSPECTRUM_MACHINE_UNKNOWN:
			messageLabel.text = NSLocalizedString("Type `LOAD \"\"` and press ENTER")
		default:
			messageLabel.text = NSLocalizedString("Select `Tape Loader` option and press ENTER")
		}
	}
}

// MARK: - Signals handling

extension TapeViewController {
	
	fileprivate func setupSelectedMachineSignal() {
		Defaults.selectedMachine.bind(to: self) { me, value in
			gverbose("Machine selection changed to \(value)")
			me.setupMessage()
		}
	}
	
	fileprivate func setupCurrentObjectSignal() {
		Defaults.currentFile.bind(to: self) { me, value in
			gverbose("Updating for object ID \(String(describing: value))")
			me.setupMessage()
		}
	}
	
	fileprivate func setupTapePlayingSignal() {
		// Note we need to skip initial signal sent after setting up observation!
		Defaults.isTapePlaying.skip(first: 1).bind(to: self) { me, value in
			gverbose("Tape playing status changed to \(value)")
			me.setupMessage()
		}
	}
}
