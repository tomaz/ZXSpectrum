//
//  Created by Tomaz Kragelj on 8.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import SwiftRichString
import Bond

/**
Simulates joystick.
*/
final class JoystickViewController: UIViewController {
	
	@IBOutlet fileprivate weak var mainStackView: UIStackView!
	@IBOutlet fileprivate weak var joystickStackView: UIStackView!
	@IBOutlet fileprivate weak var buttonsStackView: UIStackView!
	
	@IBOutlet fileprivate weak var stickTouchView: TouchableView!
	@IBOutlet fileprivate weak var stickView: JoystickStickView!
	
	@IBOutlet fileprivate weak var spacerView: UIView!
	
	@IBOutlet fileprivate weak var buttonTouchView: TouchableView!
	@IBOutlet fileprivate weak var button1View: JoystickButtonView!
	@IBOutlet fileprivate weak var button2View: JoystickButtonView!
	@IBOutlet fileprivate weak var button3View: JoystickButtonView!
	
	@IBOutlet fileprivate weak var editButton: UIButton!
	
	// MARK: - Dependencies
	
	fileprivate var persistentContainer: NSPersistentContainer!
	
	// MARK: - Data
	
	fileprivate var file: FileObject?
	fileprivate var lastStickActive = false
	fileprivate var lastStickAngle = CGFloat.greatestFiniteMagnitude
	fileprivate var lastKeys: [KeyCode]?
	
	// MARK: - Initialization & disposal
	
	/**
	Creates and returns new instance.
	*/
	static func instantiate() -> JoystickViewController {
		let storyboard = UIViewController.current.storyboard!
		return storyboard.instantiateViewController(withIdentifier: "JoystickScene") as! JoystickViewController
	}
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		gdebug("Setting up view")
		establishDefaultAppearance()
		establishStickSettings()
		updateFileForCurrentSelection()
		
		setupStickTouchesHandler()
		setupButtonTouchesHandler()
		
		setupCurrentFileSignal()
		setupJoystickSensitivityRatioSignal()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		inject(toController: segue.destination) { me, destination in
			if let editor = destination as? JoystickKeyCodeSelectionHandlerConsumer {
				editor.configure(selectionChangeHandler: self.provideSelectionChangeHandler())
			}
		}
	}
}

// MARK: - Dependencies

extension JoystickViewController: PersistentContainerConsumer, PersistentContainerProvider {
	
	func configure(persistentContainer: NSPersistentContainer) {
		gdebug("Configuring with \(persistentContainer)")
		self.persistentContainer = persistentContainer
	}
	
	func providePersistentContainer() -> NSPersistentContainer {
		gdebug("Providing persistent container")
		return persistentContainer
	}
}

extension JoystickViewController: JoystickKeyCodeSelectionHandlerProvider {
	
	func provideSelectionChangeHandler() -> JoystickKeyCodeSelectionHandler {
		gdebug("Providing selection change handler")
		return { codes in
			self.updateViewsForCurrentFile()
		}
	}
}

// MARK: - View updating

extension JoystickViewController {
	
	/**
	Updates views according to current status.
	*/
	fileprivate func updateFileForCurrentSelection() {
		let objectID = Defaults.currentObjectID.value
		gdebug("Updating file for ID \(String(describing: objectID))")
		
		if let id = objectID {
			let context = persistentContainer.viewContext
			file = context.object(with: id) as? FileObject
		} else {
			file = nil
		}
		
		updateViewsForCurrentFile()
	}
	
	/**
	Updates all views for currently assigned `file`.
	*/
	fileprivate func updateViewsForCurrentFile() {
		gverbose("Updating views for \(String(describing: file))")
		
		guard let file = file else {
			gdebug("No file selected, hiding controls")
			editButton.isHidden = true
			button1View.isLarge = true
			button2View.isHidden = true
			button3View.isHidden = true
			return
		}

		let joystickMapping = file.joystickMapping
		let mappedButtons = joystickMapping?.mappedButtonsCount ?? 0
		
		func isBound(mapping: JoystickMappingObject.Mapping) -> Bool {
			return joystickMapping?.isBound(mapping: mapping) ?? false
		}

		gdebug("File selected, setting up views.")
		button1View.isLarge = mappedButtons <= 1
		button1View.text = KeyCode.description(keys: joystickMapping?.button1Keys)
			
		button2View.isHidden = mappedButtons <= 1 || !isBound(mapping: .button2)
		button2View.text = KeyCode.description(keys: joystickMapping?.button2Keys)
		
		button3View.isHidden = mappedButtons <= 1 || !isBound(mapping: .button3)
		button3View.text = KeyCode.description(keys: joystickMapping?.button3Keys)
		
		editButton.attributedTitle = JoystickViewController.editText(for: file.joystickMapping)
		editButton.isHidden = false
	}
}

// MARK: - Joystick polling

extension JoystickViewController {
	
	/**
	Polls the joystick and sends events to fuse.
	*/
	func poll() {
		// Nothing to do here until we actually support real joystick; we're just simulating keyboard events which we push as soon as events occur.
	}
}

// MARK: - Stick events handling

extension JoystickViewController {
	
	fileprivate func setupStickTouchesHandler() {
		stickTouchView.didMoveFromStartingTouch = { angle, distance in
			self.stickView.updateIndicator(distance: distance, angle: angle)

			let isStickActive = distance > 0
			let isStickChange = isStickActive != self.lastStickActive
			
			if isStickChange || angle != self.lastStickAngle {
				// If user depresses stick, notify fuse about release state for previous keys (if any).
				if !isStickActive {
					if let previouslyPressedKeys = self.lastKeys {
						KeyCode.inject(keys: previouslyPressedKeys, pressed: false)
					}
					self.lastStickActive = false
					self.lastKeys = nil
					return
				}
				
				// If user presses the stick, report changes to fuse.
				if let mapping = self.file?.joystickMapping {
					let lastKeys = self.lastKeys ?? []
					let pressedKeys = mapping.keys(for: angle) ?? []
					let releasedKeys = lastKeys.filter { !pressedKeys.contains($0) }
					let newlyPressedKeys = pressedKeys.filter { !lastKeys.contains($0) }

					self.lastKeys = pressedKeys
					
					KeyCode.inject(keys: releasedKeys, pressed: false)
					KeyCode.inject(keys: newlyPressedKeys, pressed: true)
				}
				
				// Remember last stick angle and active status.
				self.lastStickActive = isStickActive
				self.lastStickAngle = angle
			}
		}
	}
}

// MARK: - Button events handling

extension JoystickViewController {
	
	fileprivate func setupButtonTouchesHandler() {
		buttonTouchView.didGetTouchOnSubview = { subview, pressed in
			let keys = self.keys(for: subview)
			KeyCode.inject(keys: keys, pressed: pressed)
		}
	}
	
	private func keys(for button: UIView) -> [KeyCode]? {
		if let mapping = file?.joystickMapping {
			switch button {
			case button1View: return mapping.button1Keys
			case button2View: return mapping.button2Keys
			case button3View: return mapping.button3Keys
			default: break
			}
		}
		return nil
	}
}

// MARK: - Helper functions

extension JoystickViewController {
	
	fileprivate func establishDefaultAppearance() {
		view.backgroundColor = JoystickStyleKit.joystickBackgroundColor
		spacerView.isHidden = UIDevice.iPhone
	}
	
	fileprivate func establishStickSettings() {
		// Note we never allow sensitibyt to cause issues with joystick handling, so we limit the maximum and minimum values.
		let sensitivity = max(min(CGFloat(UserDefaults.standard.joystickSensitivityRatio), 0.9), 0.1)
		
		stickView.maximumDistance = 0.9
		
		stickTouchView.touchDetectionMinimumThreshold = sensitivity
		stickTouchView.touchDetectionMaximumThreshold = 0.9
		
		stickTouchView.touchDetectionDistanceThreshold = 2
		stickTouchView.touchDetectionAngleThreshold = Direction.radians(5)
		
		stickTouchView.trimToAngles = [ Direction.NW, Direction.N, Direction.NE, Direction.E, Direction.SE, Direction.S, Direction.SW, Direction.W, ]
	}
}

// MARK: - Signals handling

extension JoystickViewController {

	fileprivate func setupCurrentFileSignal() {
		Defaults.currentObjectID.bind(to: self) { me, objectID in
			gverbose("Current object ID changed to \(String(describing: objectID))")
			UIView.animate(withDuration: 0.2) {
				me.updateFileForCurrentSelection()
			}
		}
	}
	
	fileprivate func setupJoystickSensitivityRatioSignal() {
		UserDefaults.standard.reactive.joystickSensitivityRatioSignal.bind(to: self) { me, value in
			gverbose("Joystick sensitivity ratio changed to \(value)")
			me.establishStickSettings()
		}
	}
}

// MARK: - Styling

extension JoystickViewController {
	
	/**
	Prepares edit button text.
	*/
	fileprivate static func editText(for mapping: JoystickMappingObject?) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		let fontSize = CGFloat(15)

		if let mapping = mapping, !mapping.isEmpty {
			result.append("✓".set(style: Style("checkmark", {
				$0.font = FontAttribute(font: UIFont.systemFont(ofSize: fontSize))
				$0.color = UIColor(white: 0.6, alpha: 1)
			})))
		}
		
		result.append(NSLocalizedString("Edit").set(style: Style("edit", {
			$0.font = FontAttribute(font: UIFont.systemFont(ofSize: fontSize))
			$0.color = UIColor.white
		})))
		
		return result
	}
}
