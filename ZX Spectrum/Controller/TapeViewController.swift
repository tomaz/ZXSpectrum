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
	
	@IBOutlet fileprivate weak var actionButton: UIButton!
	
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
		updateActionButton()
		
		gdebug("Setting up signals")
		setupCurrentObjectSignal()
		setupTapePlayingSignal()
		setupActionButtonTapSignal()
	}
}

// MARK: - User interface

extension TapeViewController {
	
	fileprivate func setupActionButton() {
		actionButton.layer.cornerRadius = 4
		actionButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
	}
	
	fileprivate func updateActionButton() {
		actionButton.title = Defaults.isTapePlaying.value ? NSLocalizedString("STOP") : NSLocalizedString("PLAY")
		actionButton.isEnabled = Defaults.currentFile.value != nil
	}
}

// MARK: - Signals handling

extension TapeViewController {
	
	fileprivate func setupCurrentObjectSignal() {
		Defaults.currentFile.bind(to: self) { me, value in
			gverbose("Updating for object ID \(String(describing: value))")
			me.updateActionButton()
		}
	}
	
	fileprivate func setupTapePlayingSignal() {
		// Note we need to skip initial signal sent after setting up observation!
		Defaults.isTapePlaying.skip(first: 1).bind(to: self) { me, value in
			gverbose("Tape playing status changed to \(value)")
			me.updateActionButton()
		}
	}
	
	fileprivate func setupActionButtonTapSignal() {
		// After user taps on play button, toggle playback; this will in turn send event to `isTapePlaying` signal.
		actionButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Toggling playback to \(!Defaults.isTapePlaying.value)")
			tape_toggle_play(0)
		}
	}
}
