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
		Defaults.isTapePlaying.bind(to: self) { me, value in
			gverbose("Tape playing status changed to \(value)")
			me.updateActionButton()
		}
	}
	
	fileprivate func setupActionButtonTapSignal() {
		actionButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Toggling playback to \(!Defaults.isTapePlaying.value)")
			Defaults.isTapePlaying.value = !Defaults.isTapePlaying.value
		}
	}
}
