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
	
	fileprivate var startGlowAnimationWhenViewAppears = false
	fileprivate var isGlowAnimationActive = false
	
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
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if startGlowAnimationWhenViewAppears {
			setupGlow()
			startGlowAnimationWhenViewAppears = false
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if isGlowAnimationActive {
			setupGlow(remove: true)
			startGlowAnimationWhenViewAppears = true
		}
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

extension JoystickViewController: PopoverPresentationStatusConsumer {
	
	func popoverWillPresent(controller: UIViewController) {
		gverbose("Popover will present")
		Defaults.isEmulationStarted.value = false
	}
	
	func popoverDidDismiss(controller: UIViewController) {
		gverbose("Popover did dismiss")
		Defaults.isEmulationStarted.value = true
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

		setupGlow(remove: joystickMapping != nil)
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
		// Note we never allow sensitibility to cause issues with joystick handling, so we limit the maximum and minimum values.
		let sensitivity = min(max(CGFloat(UserDefaults.standard.joystickSensitivityRatio), 0.1), 0.8)
		let maximumThreshold = max(sensitivity, 0.8)
		
		stickView.maximumDistanceRatio = maximumThreshold
		
		stickTouchView.touchDetectionMinimumThreshold = sensitivity
		stickTouchView.touchDetectionMaximumThreshold = maximumThreshold
		
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
	
	fileprivate func setupGlow(remove: Bool = false) {
		if let layer = editButton.titleLabel?.layer {
			if !remove {
				isGlowAnimationActive = true
				
				if isViewLoaded && view.window == nil {
					startGlowAnimationWhenViewAppears = true
					return
				}
				
				CATransaction.begin()
				
				// Setup layer shadow.
				layer.masksToBounds = false
				layer.shadowColor = UIColor.white.cgColor
				layer.shadowOffset = CGSize(width: 0, height: 0)
				layer.shadowRadius = 0 // start hidden
				layer.shadowOpacity = 0 // start hidden
				
				// Setup radius animation.
				let radiusAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowRadius))
				radiusAnimation.fromValue = 0
				radiusAnimation.toValue = 5
				radiusAnimation.duration = 0.5
				radiusAnimation.autoreverses = true
				radiusAnimation.repeatCount = Float.greatestFiniteMagnitude
				radiusAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
				
				// Setup opacity animation.
				let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOpacity))
				opacityAnimation.fromValue = 0
				opacityAnimation.toValue = 1
				opacityAnimation.autoreverses = radiusAnimation.autoreverses
				opacityAnimation.duration = radiusAnimation.duration
				opacityAnimation.repeatCount = radiusAnimation.repeatCount
				opacityAnimation.timingFunction = radiusAnimation.timingFunction
				
				// Add both animations.
				layer.add(radiusAnimation, forKey: nil)
				layer.add(opacityAnimation, forKey: nil)
				
				CATransaction.commit()
			} else {
				// Just in case we have scheduled animation on view appearance; don't do it.
				startGlowAnimationWhenViewAppears = false
				isGlowAnimationActive = false
				
				// Remove animations.
				layer.removeAllAnimations()
				
				// Reset shadow.
				layer.masksToBounds = true
				layer.shadowOpacity = 0.0
			}
		}
	}
}
