//
//  Created by Tomaz Kragelj on 11.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
ZX 48K style keyboard.
*/
final class KeyboardViewController: UIViewController {
	
	// MARK: - Data
	
	/// Currently selected keyboard.
	fileprivate var selectedKeyboard: Keyboard = .ZX48K

	// MARK: - Initialization & disposal
	
	/**
	Creates and returns new instance.
	*/
	static func instantiate() -> KeyboardViewController {
		let storyboard = UIViewController.current.storyboard!
		return storyboard.instantiateViewController(withIdentifier: "KeyboardScene") as! KeyboardViewController
	}
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		gdebug("Setting up views")
		selectKeyboardForCurrentMachine(force: true, animated: false)
		
		gdebug("Setting up signals")
		setupSelectedMachineSignal()
	}
}

// MARK: - Helper functions

extension KeyboardViewController {

	/**
	Selects keyboard for currently selected machine.
	*/
	func selectKeyboardForCurrentMachine() {
		selectKeyboardForCurrentMachine(animated: true)
	}

	/**
	Selects given keyboard.
	*/
	func select(keyboard: Keyboard) {
		select(keyboard: keyboard, animated: true)
	}

	/**
	Underlying keyboard selection function for current machine type.
	
	Note: while this could easily be made public and replace need for public/internal function pair, the reason for splitting them is I don't want to open up force and animated parameters to public API. All changes arriving from outside must be non-forced and animated, it's only internal changes that can sometimes be forced or non-animated!
	*/
	fileprivate func selectKeyboardForCurrentMachine(force: Bool = false, animated: Bool = true) {
		func keyboardForSelectedMachine() -> Keyboard {
			switch SpectrumController().selectedMachineType {
			case LIBSPECTRUM_MACHINE_16: fallthrough
			case LIBSPECTRUM_MACHINE_48: fallthrough
			case LIBSPECTRUM_MACHINE_UNKNOWN:
				return .ZX48K
			default:
				return .ZX128K
			}
		}

		// Prepare keyboard.
		let newKeyboard = keyboardForSelectedMachine()
		gverbose("Requesting \(newKeyboard) keyboard")

		// If change is not forced, only do it if different type of keyboard is selected.
		if !force && newKeyboard == selectedKeyboard {
			gdebug("Keyboard already shown, ignoring")
			return
		}
		
		// Change the keyboard.
		select(keyboard: newKeyboard, animated: true)
	}
	
	/**
	Underlying function for selecting arbitrary keyboard.
	
	Note: while this could easily be made public and replace need for public/internal functions pair, the reason for splitting them is I don't want to open up `animated` parameter to public API. All changes arriving from outside must be animated, it's only internal changes that can sometimes be non animated.
	*/
	fileprivate func select(keyboard: Keyboard, animated: Bool = true) {
		gdebug("Selecting \(keyboard)")
		
		let currentKeyboard = view.subviews.first
		
		@discardableResult func addNewKeyboard() -> UIView {
			// Prepare correct view.
			let keyboardView = keyboard.view
			keyboardView.translatesAutoresizingMaskIntoConstraints = false
			keyboardView.frame = view.bounds
			view.addSubview(keyboardView)
			
			// Setup layout.
			keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
			keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
			keyboardView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
			keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
			
			return keyboardView
		}
		
		func removePreviousKeyboard() {
			currentKeyboard?.removeFromSuperview()
		}
		
		// Update current selection.
		selectedKeyboard = keyboard
		
		// For non animated change, simply swap the views. Also use non animated if this is initial setup.
		if !animated || currentKeyboard == nil {
			removePreviousKeyboard()
			addNewKeyboard()
			return
		}
		
		// When animating, we simultaneously fade old keyboard view out and new one in, then, when done, remove old view.
		let newKeyboard = addNewKeyboard()
		
		newKeyboard.alpha = 0
		currentKeyboard?.alpha = 1

		UIView.animate(withDuration: 0.2, animations: {
			newKeyboard.alpha = 1
			currentKeyboard?.alpha = 0
		}) { finished in
			removePreviousKeyboard()
		}
	}
}

// MARK: - Signals handling

extension KeyboardViewController {
	
	fileprivate func setupSelectedMachineSignal() {
		Defaults.selectedMachine.bind(to: self) { me, value in
			gverbose("Selected machine changed to \(value)")
			me.selectKeyboardForCurrentMachine()
		}
	}
}

// MARK: - Declarations

extension KeyboardViewController {
	
	enum Keyboard: Int {
		case ZX48K
		case ZX128K
		
		var view: BaseKeyboardView {
			switch self {
			case .ZX48K: return ZX48KeyboardView()
			case .ZX128K: return ZX128KeyboardView()
			}
		}
		
		static var all: [Keyboard] {
			return [ .ZX48K, .ZX128K ]
		}
	}
}
