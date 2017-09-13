//
//  Created by Tomaz Kragelj on 13.09.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

/**
Manages tape view.
*/
class TapeViewController: UIViewController {
	
	@IBOutlet fileprivate weak var snapshotLabel: UILabel!
	@IBOutlet fileprivate weak var loadSnapshotButton: UIButton!
	@IBOutlet fileprivate weak var saveSnapshotButton: UIButton!
	@IBOutlet fileprivate weak var deleteSnapshotButton: UIButton!
	
	// MARK: - Signals
	
	fileprivate let isSnapshotAvailable = Property(false)

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
		
		gdebug("Setting up views")
		setup(label: snapshotLabel)
		setup(button: loadSnapshotButton)
		setup(button: saveSnapshotButton)
		setup(deleteButton: deleteSnapshotButton)
		
		gdebug("Setting up signals")
		setupStatusSignals()
		setupLoadSnapshotButtonTapSignal()
		setupSaveSnapshotButtonTapSignal()
		setupDeleteSnapshotButtonTapSignal()
		
		updateAvailableProperty()
	}
}

// MARK: - Styling

extension TapeViewController {
	
	fileprivate func setup(label: UILabel) {
		let appearance = Styles.Appearance.inverted
		label.textColor = appearance.fontColor
		setupFont(for: label, appearance: appearance)
	}
	
	fileprivate func setup(button: UIButton) {
		let appearance: Styles.Appearance = [ .inverted, .emphasized ]
		button.tintColor = appearance.fontColor
		setupFont(for: button.titleLabel, appearance: appearance)
	}
	
	fileprivate func setup(deleteButton: UIButton) {
		let appearance: Styles.Appearance = [ .inverted, .emphasized ]
		deleteButton.title = nil
		deleteButton.image = IconsStyleKit.imageOfIconTrash
		deleteButton.tintColor = appearance.fontColor
	}
	
	private func setupFont(for label: UILabel?, appearance: Styles.Appearance) {
		if let label = label {
			label.font = UIFont.monospacedDigitSystemFont(ofSize: label.font.pointSize, weight: appearance.fontWeight)
		}
	}
}

// MARK: - Signals handling

extension TapeViewController {
	
	fileprivate func updateAvailableProperty() {
		gverbose("Determining snapshot availability")
		
		guard let object = Defaults.currentFile.value else {
			gdebug("File not inserted")
			isSnapshotAvailable.value = false
			return
		}
		
		let size = Database.snapshotSize(for: object)
		gdebug("Snapshot size is \(size)")
		isSnapshotAvailable.value = size > 0
	}
	
	fileprivate func setupStatusSignals() {
		// We only allow interacting with snapshots when we have file inserted and tape isn't playing.
		let canManageSnapshots = combineLatest(Defaults.currentFile, Defaults.isTapePlaying) { object, playing in
			return object != nil && !playing
		}
		
		// We only allow loading if file is inserted, tape is playing and snapshot exists.
		let canLoadSnapshots = combineLatest(canManageSnapshots, isSnapshotAvailable) { manage, available in
			return manage && available
		}
		
		canManageSnapshots.bind(to: saveSnapshotButton.reactive.isEnabled)
		canLoadSnapshots.bind(to: loadSnapshotButton.reactive.isEnabled)
		canLoadSnapshots.bind(to: deleteSnapshotButton.reactive.isEnabled)
	}
	
	fileprivate func setupLoadSnapshotButtonTapSignal() {
		loadSnapshotButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Asking for snapshot delete confirmation")
			
			let alert = UIAlertController(title: NSLocalizedString("Open Snapshop?"), message: NSLocalizedString("This will reset to last saved state. You will lose all progress since. Are you sure?"), preferredStyle: .actionSheet)
			
			alert.addAction(UIAlertAction(title: NSLocalizedString("Open"), style: .default) { action in
				ginfo("Loading snapshot")
				Database.openSnapshot(for: Defaults.currentFile.value!)
			})
			
			alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel, handler: nil))
			
			me.present(alert, animated: true, completion: nil)
		}
	}

	fileprivate func setupSaveSnapshotButtonTapSignal() {
		saveSnapshotButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Saving snapshot")
			do {
				try Database.saveSnapshot(for: Defaults.currentFile.value!)
			} catch {
				gwarn("Snapshot failed saving \(error)")
			}
			me.updateAvailableProperty()
		}
	}
	
	fileprivate func setupDeleteSnapshotButtonTapSignal() {
		deleteSnapshotButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Asking for snapshot delete confirmation")
			
			let object = Defaults.currentFile.value!
			let bytes = Database.snapshotSize(for: object)
			let size = Formatter.size(fromBytes: bytes)
			
			let message = NSLocalizedString("This will free \(size.value) \(size.unit) but cannot be undone.\nAre you sure?")
			let alert = UIAlertController(title: NSLocalizedString("Delete Snapshop?"), message: message, preferredStyle: .actionSheet)
			
			alert.addAction(UIAlertAction(title: NSLocalizedString("Delete"), style: .destructive) { action in
				ginfo("Deleting snapshot")
				do {
					try Database.deleteSnapshot(for: object)
				} catch {
					gwarn("Failed deleting snapshot \(error)")
				}
				me.updateAvailableProperty()
			})
			
			alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel, handler: nil))
			
			me.present(alert, animated: true, completion: nil)
		}
	}
}
