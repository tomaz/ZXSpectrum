//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Keyboard container view; allows hotswapping different views on the fly.
*/
final class KeyboardView: UIView {
	
	fileprivate var joystickView: JoystickView!
	fileprivate var zx48KeyboardView: ZX48KeyboardView!
	
	fileprivate var currentKeyboardView: UIView? = nil
	fileprivate var currentKeyboardTopConstraint: NSLayoutConstraint? = nil
	
	fileprivate var transitioningKeyboardView: UIView? = nil
	fileprivate var transitioningKeyboardTopConstraint: NSLayoutConstraint? = nil
	
	// MARK: - Initialization & disposal

	convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 0, height: KeyboardView.height))
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
		return CGSize(width: UIViewNoIntrinsicMetric, height: KeyboardView.height)
	}
}

// MARK: - Initialization

extension KeyboardView {
	
	/**
	Sets up the view.
	*/
	fileprivate func initializeView() {
		// Don't want views appearing outside bounds during animations.
		layer.masksToBounds = true

		// Use same background color as subviews so animations appear less "jagged".
		backgroundColor = ZX48KeyboardStyleKit.keyboardBackgroundColor

		// Prepare joystick view
		joystickView = JoystickView()
		joystickView.translatesAutoresizingMaskIntoConstraints = false
		
		// Prepare ZX 48K keyboard view.
		zx48KeyboardView = ZX48KeyboardView()
		zx48KeyboardView.translatesAutoresizingMaskIntoConstraints = false
		
		// Setup visibility for keyboards based on current status.
		prepareForKeyboardsChange()
		completeKeyboardsChange()
		
		// Setup various observations.
		setupInputMethosSettingSignal()
	}
	
	private func setupInputMethosSettingSignal() {
		// When input method changes, swap the views.
		UserDefaults.standard.reactive.isInputJoystickSignal.bind(to: self) { me, value in
			gverbose("Joystick setting changed to \(value), swapping input method")
			
			me.prepareForKeyboardsChange()
			
			KeyboardView.animate(me.layoutIfNeeded, completion: me.completeKeyboardsChange(complete:))
		}
	}
	
	private func addSubviewAndSetupDefaultConstraints(for view: UIView) {
		// Views always take full height, we want them sliding in and our, as default keyboard does, not getting stretched and squashed!
		addSubview(view)
		view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		view.heightAnchor.constraint(equalToConstant: KeyboardView.height).isActive = true
	}
	
	private func prepareForKeyboardsChange() {
		// Prepare the view we want to show.
		let isJoystick = UserDefaults.standard.isInputJoystick
		let newKeyboardView = isJoystick ? joystickView : zx48KeyboardView
		
		// Ignore if we want to show the same view as we already are showing.
		if newKeyboardView.superview != nil {
			return
		}

		// First we need to add the keyboard view to hierarhcy and establish default constraints.
		addSubviewAndSetupDefaultConstraints(for: newKeyboardView)
		
		// If we don't have top contraint yet, this is the first time we're here, so just remember the view and exit (we'll setup top constraint in `cleanupKeyboardsAnimations(complete:)`)..
		guard let view = currentKeyboardView, let constraint = currentKeyboardTopConstraint else {
			currentKeyboardView = newKeyboardView
			return
		}
		
		// When animating, we should prepare starting frame.
		newKeyboardView.frame = CGRect(x: 0, y: bounds.maxY, width: bounds.width, height: bounds.height)
		
		// We always slide new view from the bottom, so setup temporary constraint used for transition to pin new keyboard below current one.
		transitioningKeyboardTopConstraint = newKeyboardView.topAnchor.constraint(equalTo: view.bottomAnchor)
		transitioningKeyboardTopConstraint?.isActive = true
		
		// Remember both views.
		transitioningKeyboardView = view
		currentKeyboardView = newKeyboardView
		
		// Now move current view towards the top; this will make it appear as if current view clides out and new view slides in.
		constraint.constant = -KeyboardView.height
	}
	
	private func completeKeyboardsChange(complete: Bool = true) {
		// After animations are complete, we should remove temporary constraints.
		if complete {
			// Remove previous keyboard view from hierarhcy.
			transitioningKeyboardView?.removeFromSuperview()
			transitioningKeyboardTopConstraint = nil
			
			// Establish constraints so that current view is pinned to the top.
			currentKeyboardTopConstraint = currentKeyboardView?.topAnchor.constraint(equalTo: topAnchor)
			currentKeyboardTopConstraint?.isActive = true
		}
	}
}

// MARK: - Shared functinoality

extension KeyboardView {
	
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

extension KeyboardView {
	
	fileprivate static let height = CGFloat(300)
}
