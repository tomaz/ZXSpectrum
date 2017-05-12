//
//  Created by Tomaz Kragelj on 11.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
ZX 48K style keyboard.
*/
final class KeyboardViewController: UIViewController {
	
	@IBOutlet fileprivate weak var scrollView: UIScrollView!
	
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
		setupKeyboards()
	}
}

// MARK: - UIScrollViewDelegate

extension KeyboardViewController: UIScrollViewDelegate {
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			updateSelectedKeyboard()
		}
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		updateSelectedKeyboard()
	}
}

// MARK: - Helper functions

extension KeyboardViewController {
	
	fileprivate func setupKeyboards() {
		var viewFrame = scrollView.bounds
		var previousView: UIView? = nil
		
		for view in Keyboard.all.map({ $0.view }) {
			// Prepare the view.
			view.frame = viewFrame
			view.translatesAutoresizingMaskIntoConstraints = false

			// Add to scroll view.
			scrollView.addSubview(view)
			
			// Prepare constraints. First view must be pinned to scroll view left edge, others to their previous view.
			view.leadingAnchor.constraint(equalTo: previousView?.trailingAnchor ?? scrollView.leadingAnchor).isActive = true
			view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
			view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
			view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
			view.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
			
			// Prepare for next iteration
			previousView = view
			viewFrame.origin.x += viewFrame.width
		}
		
		// Last view must be pinned to scroll view right edge.
		if let lastView = previousView {
			lastView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
		}
	}
	
	fileprivate func updateSelectedKeyboard() {
		if scrollView.contentOffset.x >= scrollView.frame.width {
			selectedKeyboard = .ZX128K
		} else {
			selectedKeyboard = .ZX48K
		}
		
		let keyboardView = scrollView.subviews[selectedKeyboard.rawValue]
		view.backgroundColor = keyboardView.backgroundColor
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
