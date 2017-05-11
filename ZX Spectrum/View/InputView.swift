//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData

/**
Input container view; allows hotswapping different views on the fly.
*/
final class InputView: UIView {
	
	fileprivate var persistentContainer: NSPersistentContainer!
	
	fileprivate var joystickViewController: JoystickViewController!
	fileprivate var keyboardViewController: KeyboardViewController!
	
	fileprivate var currentInputView: UIView? = nil
	fileprivate var currentKeyboardTopConstraint: NSLayoutConstraint? = nil
	
	fileprivate var transitioningKeyboardView: UIView? = nil
	fileprivate var transitioningKeyboardTopConstraint: NSLayoutConstraint? = nil
	
	fileprivate lazy var joystickController = SpectrumJoystickController()
	
	// MARK: - Initialization & disposal

	convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 0, height: InputView.height))
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
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIViewNoIntrinsicMetric, height: InputView.height)
	}
}

// MARK: - Dependencies

extension InputView: PersistentContainerConsumer, PersistentContainerProvider {
	
	func configure(persistentContainer: NSPersistentContainer) {
		gdebug("Configuring with \(persistentContainer)")
		self.persistentContainer = persistentContainer
	}
	
	func providePersistentContainer() -> NSPersistentContainer {
		gdebug("Providing \(persistentContainer)")
		return persistentContainer
	}
}

extension InputView: InjectionObservable {
	
	func injectionDidComplete() {
		gdebug("Injection did complete")
		inject(toController: joystickViewController)
	}
}

// MARK: - SpectrumJoystickHandler

extension InputView: SpectrumJoystickHandler {
	
	func numberOfJoysticks(for controller: SpectrumJoystickController) -> Int {
		settings_current.joystick_1_output = Int32(JOYSTICK_TYPE_KEMPSTON.rawValue)
		return 1
	}
	
	func pollJoysticks(for controller: SpectrumJoystickController) {
		joystickViewController.poll()
	}
}

// MARK: - Initialization

extension InputView {
	
	/**
	Sets up the view.
	*/
	fileprivate func initializeView() {
		// Don't want views appearing outside bounds during animations.
		layer.masksToBounds = true

		// Use same background color as subviews so animations appear less "jagged".
		backgroundColor = ZX48KeyboardStyleKit.keyboardBackgroundColor
		
		// Prepare joystick view
		joystickViewController = JoystickViewController.instantiate()
		
		// Prepare ZX 48K keyboard view.
		keyboardViewController = KeyboardViewController.instantiate()
		
		// Setup joystick controller handler.
		joystickController.handler = self
		
		// Setup visibility for keyboards based on current status.
		prepareForKeyboardsChange()
		completeKeyboardsChange()
		
		// Setup various observations.
		setupInputMethodSettingSignal()
	}
	
	private func setupInputMethodSettingSignal() {
		// When input method changes, swap the views.
		Defaults.isInputJoystick.bind(to: self) { me, value in
			gverbose("Joystick setting changed to \(value), swapping input method")
			
			me.prepareForKeyboardsChange()
			
			InputView.animate(me.layoutIfNeeded, completion: me.completeKeyboardsChange(complete:))
		}
	}
	
	private func addSubviewAndSetupDefaultConstraints(for view: UIView) {
		// Views always take full height, we want them sliding in and our, as default keyboard does, not getting stretched and squashed!
		addSubview(view)
		view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		view.heightAnchor.constraint(equalToConstant: InputView.height).isActive = true
	}
	
	private func prepareForKeyboardsChange() {
		// Prepare the view we want to show.
		let isJoystick = Defaults.isInputJoystick.value
		let newInputView = isJoystick ? joystickViewController.view! : keyboardViewController.view!
		
		// Ignore if we want to show the same view as we already are showing.
		if newInputView.superview != nil {
			return
		}
		
		newInputView.translatesAutoresizingMaskIntoConstraints = false

		// First we need to add the keyboard view to hierarhcy and establish default constraints.
		addSubviewAndSetupDefaultConstraints(for: newInputView)
		
		// If we don't have top contraint yet, this is the first time we're here, so just remember the view and exit (we'll setup top constraint in `cleanupKeyboardsAnimations(complete:)`)..
		guard let view = currentInputView, let constraint = currentKeyboardTopConstraint else {
			currentInputView = newInputView
			return
		}
		
		// When animating, we should prepare starting frame.
		newInputView.frame = CGRect(x: 0, y: bounds.maxY, width: bounds.width, height: bounds.height)
		
		// We always slide new view from the bottom, so setup temporary constraint used for transition to pin new keyboard below current one.
		transitioningKeyboardTopConstraint = newInputView.topAnchor.constraint(equalTo: view.bottomAnchor)
		transitioningKeyboardTopConstraint?.isActive = true
		
		// Remember both views.
		transitioningKeyboardView = view
		currentInputView = newInputView
		
		// Now move current view towards the top; this will make it appear as if current view clides out and new view slides in.
		constraint.constant = -InputView.height
	}
	
	private func completeKeyboardsChange(complete: Bool = true) {
		// After animations are complete, we should remove temporary constraints.
		if complete {
			// Remove previous keyboard view from hierarhcy.
			transitioningKeyboardView?.removeFromSuperview()
			transitioningKeyboardTopConstraint = nil
			
			// Establish constraints so that current view is pinned to the top.
			currentKeyboardTopConstraint = currentInputView?.topAnchor.constraint(equalTo: topAnchor)
			currentKeyboardTopConstraint?.isActive = true
		}
	}
}

// MARK: - Shared functinoality

extension InputView {
	
	/**
	Performs standard animation for keyboard views.
	*/
	static func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
		UIView.animate(
			withDuration: 0.4,
			delay: 0.0,
			usingSpringWithDamping: 0.6,
			initialSpringVelocity: 0.0,
			options: .curveEaseInOut,
			animations: animations,
			completion: completion)
	}
}

// MARK: - Constants

extension InputView {
	
	fileprivate static let height = CGFloat(300)
}
