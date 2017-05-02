//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Represents joystick input view.
*/
final class JoystickView: UIView {
	
	fileprivate var editButton: UIButton!
	fileprivate var assignButton: UIButton!
	fileprivate var upEditButton: UIButton!
	fileprivate var downEditButton: UIButton!
	fileprivate var leftEditButton: UIButton!
	fileprivate var rightEditButton: UIButton!
	fileprivate var fireEditButton: UIButton!
	
	/// The index of the joystick this view represents.
	fileprivate lazy var joystickIndex: Int32 = 0
	
	/// Current joystick stick position or nil if none.
	fileprivate lazy var stick: joystick_button? = nil

	/// Current joystick button status or nil if none.
	fileprivate lazy var button: joystick_button? = nil
	
	/// Current joystick stick position or nil if none.
	fileprivate lazy var previousStick: joystick_button? = nil
	
	/// Current joystick button status or nil if none.
	fileprivate lazy var previousButton: joystick_button? = nil

	/// Keyboard mapping for stick up or nil if it should be treated as normal joystick.
	fileprivate lazy var keyboardMappingUp: keyboard_key_name? = nil
	
	/// Keyboard mapping for stick down or nil if it should be treated as normal joystick.
	fileprivate lazy var keyboardMappingDown: keyboard_key_name? = nil
	
	/// Keyboard mapping for stick left or nil if it should be treated as normal joystick.
	fileprivate lazy var keyboardMappingLeft: keyboard_key_name? = nil
	
	/// Keyboard mapping for stick right or nil if it should be treated as normal joystick.
	fileprivate lazy var keyboardMappingRight: keyboard_key_name? = nil
	
	/// Keyboard mapping for joystick fire button or nil if it should be treated as normal joystick.
	fileprivate lazy var keyboardMappingFire: keyboard_key_name? = nil
	
	/// Data used for managing joystick state values.
	fileprivate lazy var data = Data()
	
	/// Thumb background view.
	fileprivate lazy var thumbBackView = DelegatedView { bounds, dirty in
		JoystickStyleKit.drawJoystickBackground(frame: bounds)
	}
	
	/// Thumb stick view.
	fileprivate lazy var thumbStickView = DelegatedView { bounds, dirty in
		JoystickStyleKit.drawJoystickThumb(frame: bounds)
	}
	
	/// Button view.
	fileprivate lazy var buttonView = DelegatedView { bounds, dirty in
		JoystickStyleKit.drawJoystickThumb(frame: bounds)
	}
	
	// MARK: - Initialization & disposal
	
	convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializeView()
	}
	
	// MARK: - Overriden functions
	
	override func layoutSubviews() {
		super.layoutSubviews()

		data.updateRects(for: bounds)

		thumbBackView.frame = data.thumbBackRect
		thumbStickView.frame = data.thumbRect
		buttonView.frame = data.buttonRect
		
		let size = upEditButton.intrinsicContentSize
		let frame = thumbBackView.frame
		let midX = frame.midX - size.width / 2
		let midY = frame.midY - size.height / 2
		
		upEditButton.frame = CGRect(x: midX, y: frame.minY, width: size.width, height: size.height)
		downEditButton.frame = CGRect(x: midX, y: frame.maxY - size.height, width: size.width, height: size.height)
		leftEditButton.frame = CGRect(x: frame.minX, y: midY, width: size.width, height: size.height)
		rightEditButton.frame = CGRect(x: frame.maxX - size.width, y: midY, width: size.width, height: size.height)
		fireEditButton.frame = CGRect(x: buttonView.frame.midX - size.width / 2, y: buttonView.frame.midY - size.width / 2, width: size.width, height: size.height)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		handle(touches: touches, moved: false, pressed: true)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		handle(touches: touches, moved: true, pressed: true)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		handle(touches: touches, moved: false, pressed: false)
	}
}

// MARK: - Initialization

extension JoystickView {
	
	fileprivate func initializeView() {
		isMultipleTouchEnabled = true
		backgroundColor = JoystickStyleKit.joystickBackgroundColor
		
		thumbBackView.backgroundColor = UIColor.clear
		thumbStickView.backgroundColor = UIColor.clear
		buttonView.backgroundColor = UIColor.clear
		
		addSubview(thumbBackView)
		addSubview(thumbStickView)
		addSubview(buttonView)
		
		editButton = initializeEditButton()
		assignButton = initializeAssignButton()
		
		upEditButton = initializeMappingButton(for: JOYSTICK_BUTTON_UP)
		downEditButton = initializeMappingButton(for: JOYSTICK_BUTTON_DOWN)
		leftEditButton = initializeMappingButton(for: JOYSTICK_BUTTON_LEFT)
		rightEditButton = initializeMappingButton(for: JOYSTICK_BUTTON_RIGHT)
		fireEditButton = initializeMappingButton(for: JOYSTICK_BUTTON_FIRE)
		
		initializeCurrentFileSignal()
	}
	
	private func initializeEditButton() -> UIButton {
		let result = UIButton(frame: CGRect.zero)
		result.translatesAutoresizingMaskIntoConstraints = false
		result.setTitle(NSLocalizedString("Edit"), for: .normal)
		
		result.reactive.tap.bind(to: self) { _ in
			ginfo("Toggling edit mode")
			self.editButton.isSelected = !self.editButton.isSelected
			
			let alpha: CGFloat = self.editButton.isSelected ? 1 : 0
			
			UIView.animate(withDuration: 0.2) {
				self.upEditButton.alpha = alpha
				self.downEditButton.alpha = alpha
				self.leftEditButton.alpha = alpha
				self.rightEditButton.alpha = alpha
				self.fireEditButton.alpha = alpha
				self.assignButton.alpha = alpha > 0 && Defaults.currentObjectID.value != nil ? 1 : 0
			}
		}

		addSubview(result)
		
		result.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		result.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
		return result
	}
	
	private func initializeAssignButton() -> UIButton {
		let result = UIButton(frame: CGRect.zero)
		result.alpha = 0
		result.translatesAutoresizingMaskIntoConstraints = false
		result.setTitle(NSLocalizedString("Assign"), for: .normal)
		
		addSubview(result)
		
		result.bottomAnchor.constraint(equalTo: editButton.bottomAnchor).isActive = true
		result.leadingAnchor.constraint(equalTo: editButton.trailingAnchor, constant: 10).isActive = true
		result.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
		
		return result
	}
	
	private func initializeMappingButton(for button: joystick_button) -> UIButton {
		let result = UIButton(frame: CGRect.zero)
		result.alpha = 0
		result.translatesAutoresizingMaskIntoConstraints = false
		result.setTitle(NSLocalizedString("..."), for: .normal)
		
		result.reactive.tap.bind(to: self) { me, event in
			ginfo("Editing \(button)")
			let current = UIViewController.current
			
			let controller = current.storyboard!.instantiateViewController(withIdentifier: "KeyboardMappingScene")
			controller.modalPresentationStyle = .popover

			// Inject dependencies; as we need additional context for `KeyCodeProvider`, we can't handle it statically, but instead provide closure for each button separately.
			me.inject(toController: controller) { source, destination in
				if let destination = destination as? KeyCodeConsumer {
					gdebug("Providing key code handler for \(button)")
					
					destination.configure(keyCodeHandler: { code in
						gverbose("Mapping \(String(describing: code)) to \(button)")
						current.dismiss(animated: true, completion: nil)
						
						result.setTitle(code?.description ?? "...", for: .normal)
						
						switch button {
						case JOYSTICK_BUTTON_UP: me.keyboardMappingUp = code
						case JOYSTICK_BUTTON_DOWN: me.keyboardMappingDown = code
						case JOYSTICK_BUTTON_LEFT: me.keyboardMappingLeft = code
						case JOYSTICK_BUTTON_RIGHT: me.keyboardMappingRight = code
						case JOYSTICK_BUTTON_FIRE: me.keyboardMappingFire = code
						default: break
						}
					})
				}
			}
			
			current.present(controller, animated: true, completion: nil)
		}
		
		addSubview(result)
		
		return result
	}
	
	private func initializeCurrentFileSignal() {
		func animate(toVisible: Bool) {
			UIView.animate(withDuration: 0.2) { 
				self.assignButton.alpha = toVisible ? 1 : 0
			}
		}
		
		Defaults.currentObjectID.bind(to: self) { _ in
			let isEditing = self.editButton.isSelected
			let isAssignVisible = self.assignButton.alpha != 0
			let isObjectAvailable = Defaults.currentObjectID.value != nil
			
			if isEditing {
				if isObjectAvailable && !isAssignVisible {
					animate(toVisible: true)
				} else if !isObjectAvailable && isAssignVisible {
					animate(toVisible: false)
				}
			}
		}
	}
}

// MARK: - Helper functions

extension JoystickView {

	/**
	Manages touches.
	*/
	fileprivate func handle(touches: Set<UITouch>, moved: Bool, pressed: Bool) {
		var stick: joystick_button? = moved ? self.stick : nil
		var button: joystick_button? = moved ? self.button : nil

		let locations = touches.map { $0.location(in: self) }
		data.handle(touches: locations, pressed: pressed) { newStick, newButton, touchesOverThumb, touchesOverButton, needsUpdate in
			if touchesOverThumb {
				stick = newStick
				self.thumbStickView.frame = self.data.thumbRect
			}
			
			if touchesOverButton {
				button = newButton
			}
		}
		
		self.stick = stick
		self.button = button
	}
}

// MARK: - SpectrumJoystickHandler

extension JoystickView {
	
	/**
	Polls the joystick into fuse.
	*/
	func poll() {
		// Stick is a bit more complicated: direction can change without being depressed.
		if let stick = stick {
			if let previous = previousStick, previous != stick {
				// We have different stick then previous, register unpress for previous and press for new.
				report(joystick: previous, press: false)
				report(joystick: stick, press: true)
				previousStick = stick
			} else if previousStick == nil {
				// We have first press of a stick, register press.
				report(joystick: stick, press: true)
				previousStick = stick
			}
		} else if let previous = previousStick, stick == nil {
			// Stick was unpressed but not yet reported, do it now.
			report(joystick: previous, press: false)
			previousStick = nil
		}
		
		// Button is simpler - it's either pressed or depressed, but we only need to report when changed.
		if let button = button, previousButton == nil {
			report(joystick: button, press: true)
			previousButton = button
		} else if let previous = previousButton, button == nil {
			report(joystick: previous, press: false)
			previousButton = nil
		}
	}
	
	private func report(joystick: joystick_button, press: Bool) {
		switch joystick {
		case JOYSTICK_BUTTON_UP:
			if let key = keyboardMappingUp {
				if press {
					keyboard_press(key)
				} else {
					keyboard_release(key)
				}
				return
			}
			
		case JOYSTICK_BUTTON_DOWN:
			if let key = keyboardMappingDown {
				if press {
					keyboard_press(key)
				} else {
					keyboard_release(key)
				}
				return
			}
			
		case JOYSTICK_BUTTON_LEFT:
			if let key = keyboardMappingLeft {
				if press {
					keyboard_press(key)
				} else {
					keyboard_release(key)
				}
				return
			}
			
		case JOYSTICK_BUTTON_RIGHT:
			if let key = keyboardMappingRight {
				if press {
					keyboard_press(key)
				} else {
					keyboard_release(key)
				}
				return
			}
			
		case JOYSTICK_BUTTON_FIRE:
			if let key = keyboardMappingFire {
				if press {
					keyboard_press(key)
				} else {
					keyboard_release(key)
				}
				return
			}
		
		default:
			break
		}
		
		joystick_press(joystickIndex, joystick, press ? 1 : 0)
	}
}

// MARK: - Declarations

extension JoystickView {

	/**
	Handles current joystick values as user touches the view.
	*/
	fileprivate class Data {

		/// Current button rectangle.
		fileprivate (set) lazy var buttonRect = CGRect()
		
		/// Current thumb background rectangle.
		fileprivate (set) lazy var thumbBackRect = CGRect()
		
		/// Current thumb rectangle (changes with movement).
		fileprivate (set) lazy var thumbRect = CGRect()
		
		/// Frame of previous stick thumb.
		private lazy var previousThumbRect = CGRect.zero
		
		/// State of button on previous call.
		private lazy var previousButton: joystick_button? = nil
		
		/// Current thumb radius.
		private lazy var thumbRadius = CGFloat(0)
		
		/// The location of thumb center point (this doesn't change with movement).
		private lazy var thumbCenterPoint = CGPoint()
		
		/// The area in which touch detection works for thumb (slightly larger than thumb itself).
		private lazy var thumbDetectionArea = CGRect()
		
		/// Maximum thumb distance from center to back area.
		private lazy var maxThumbDistance = CGFloat(0)
		
		/// Minimum distance from center to when thumb is considered active.
		private lazy var minThumbDetectionDistance = CGFloat(0)
		
		/// Last bounds.
		private lazy var bounds = CGRect.zero
		
		/// South-east direction angle in radians.
		private static let NE = -135.0 * CGFloat.pi / 180.0
		
		/// North-west direction angle in radians.
		private static let NW = -45.0 * CGFloat.pi / 180.0
		
		/// South-west direction angle in radians.
		private static let SW = 45 * CGFloat.pi / 180.0
		
		/// South-east direction angle in radians.
		private static let SE = 135 * CGFloat.pi / 180.0
		
		/**
		Updates rects for joystick buttons.
		*/
		func updateRects(for bounds: CGRect) {
			// Establish maximum sizes - this makes it fit smaller devices.
			let ratio = JoystickView.buttonSize.width / JoystickView.thumbBackSize.width
			let maxStickSize = min(bounds.width * ratio, bounds.height)
			let maxButtonSize = min(bounds.width - maxStickSize, JoystickView.buttonSize.width)
			
			let offset: CGFloat = maxButtonSize == JoystickView.buttonSize.width ? 25 : 0

			// Thumb detection area is always square and can be larger than stick area itself.
			let stickCenterY = bounds.midY
			thumbDetectionArea = CGRect(
				x: 0,
				y: 0,
				width: maxStickSize,
				height: maxStickSize)
			
			// Thumb background is on the left side.
			let thumbBackSize = maxStickSize - offset * 2
			thumbBackRect = CGRect(
				x: offset,
				y: stickCenterY - thumbBackSize / 2,
				width: thumbBackSize,
				height: thumbBackSize)
			
			// Thumb is positioned centered on the background.
			let thumbRatio = maxButtonSize / JoystickView.thumbSize.width
			let thumbSize = JoystickView.thumbSize.scaled(thumbRatio).width
			thumbRect = CGRect(
				x: offset + (thumbBackRect.width - thumbSize) / 2,
				y: stickCenterY - thumbSize / 2,
				width: thumbSize,
				height: thumbSize)
			
			// Determine maximum thumb and minimum detection distances.
			maxThumbDistance = (thumbBackSize - thumbSize) / 2
			minThumbDetectionDistance = maxThumbDistance * 0.5
			
			// Determine thumb radius and center point (these are used frequently so it's just an optimization).
			thumbRadius = thumbRect.width / 2
			thumbCenterPoint = CGPoint(x: thumbBackRect.midX, y: thumbBackRect.midY)
			
			// Button is on the right size.
			buttonRect = CGRect(
				x: bounds.maxX - maxButtonSize - offset,
				y: (bounds.height - maxButtonSize) / 2,
				width: maxButtonSize,
				height: maxButtonSize)
			
			/// Remember bounds so we can update later on.
			self.bounds = bounds
		}
		
		/**
		Handles the given touch.
		*/
		func handle(touches: [CGPoint], pressed: Bool, handler: (joystick_button?, joystick_button?, Bool, Bool, Bool) -> Void) {
			var stick: joystick_button? = nil
			var button: joystick_button? = nil
			var touchesInThumbArea = false
			var touchesInButtonArea = false
			
			if pressed {
				for location in touches {
					if thumbDetectionArea.contains(location) {
						let angle = location.angle(to: thumbCenterPoint)
						let distance = min(location.distance(to: thumbCenterPoint), maxThumbDistance)
						
						if abs(distance) > minThumbDetectionDistance {
							stick = Data.joystickStick(for: angle)
						}
						
						let x = thumbCenterPoint.x + distance * cos(angle)
						let y = thumbCenterPoint.y + distance * sin(angle)
						let position = CGPoint(x: x - thumbRadius, y: y - thumbRadius)
						thumbRect = CGRect(origin: position, size: thumbRect.size)
						
						touchesInThumbArea = true
						
					} else if buttonRect.contains(location) {
						button = JOYSTICK_BUTTON_FIRE
						touchesInButtonArea = true
					}
				}
			} else {
				updateRects(for: bounds)
				touchesInThumbArea = true // we need this so we reset position of the view
			}
			
			var update = false
			
			if pressed {
				if touchesInButtonArea && button != previousButton {
					previousButton = button
					update = true
				}
				
				if touchesInThumbArea && previousThumbRect.origin.isNoticableChange(to: thumbRect.origin) {
					previousThumbRect = thumbRect
					update = true
				}
			} else {
				previousButton = nil
				previousThumbRect = CGRect.zero
				update = true
			}
			
			handler(stick, button, touchesInThumbArea, touchesInButtonArea, update)
		}
		
		/**
		Determimes joystick button for given angle.
		*/
		fileprivate static func joystickStick(for angle: CGFloat) -> joystick_button {
			if angle >= NE && angle < NW {
				return JOYSTICK_BUTTON_UP
			} else if angle >= NW && angle < SW {
				return JOYSTICK_BUTTON_RIGHT
			} else if angle >= SW && angle < SE {
				return JOYSTICK_BUTTON_DOWN
			} else {
				return JOYSTICK_BUTTON_LEFT
			}
		}
	}
}

// MARK: - Constants

extension JoystickView {
	
	/// The size of the thumb background.
	fileprivate static let thumbBackSize = CGSize(width: 250, height: 250)
	
	/// The size of the thumb.
	fileprivate static let thumbSize = CGSize(width: 160, height: 160)
	
	/// The size of the button.
	fileprivate static let buttonSize = thumbSize
}
