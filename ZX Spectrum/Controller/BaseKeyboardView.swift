//
//  Created by Tomaz Kragelj on 12.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Base functionality for keyboard views.

This class manages most of the stuff needed for handling keyboard: scaling when view resizes, touches and reporting of pressed/released keys, optional rendering of pressed keys. All subclass must do is to provide unscaled frames and their corresponding keys as well as unscaled keyboard size (which is needed for proper scaling).

Note: subclass must override `drawKeyboard(_:)` to render the keyboard, not `draw(_:)`.
*/
class BaseKeyboardView: UIView {
	
	/**
	Rendering mode.
	
	Fit will render keyboard symmetrical based on its actual size, meaning it'll be centered on view. Fill will render is disproportionally to make it fit the view.
	*/
	var renderMode: KeyboardRenderMode = UserDefaults.standard.keyboardRenderingMode {
		didSet {
			updateScaledRects()
			setNeedsDisplay()
		}
	}
	
	/**
	Indicates whether the view shows frames around tappable areas or not (leave false for better performance).
	
	Note this is more or less useful for debugging and should be true for release builds!
	*/
	var isShowingFrames = false {
		didSet {
			setNeedsDisplay()
		}
	}
	
	/**
	Indicates whether the view shows user taps (leave false for better performance).
	*/
	var isShowingTaps = false
	
	/**
	Unscaled keyboard rect from subclass.
	*/
	fileprivate var unscaledKeyboardRect: CGRect!
	
	/**
	Map of unscaled rects with their corresponding key code.
	*/
	fileprivate var unscaledKeyRects: [CGRect: KeyCode]!
	
	/**
	Scaled rects for every key.
	*/
	fileprivate lazy var scaledRects = [CGRect: KeyCode]()
	
	/**
	Currently pressed key codes.
	*/
	fileprivate lazy var pressedKeyCodes = [KeyCode]()
	
	/**
	Currently pressed key rects.
	*/
	fileprivate lazy var pressedKeyRects = [CGRect]()
	
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
	
	private func initializeView() {
		contentMode = .redraw
		isMultipleTouchEnabled = true
		setupKeyboardModeUserDefaultSignal()
	}
	
	// MARK: - Overriden functions
	
	override func layoutSubviews() {
		super.layoutSubviews()
		updateScaledRects()
	}
	
	override func draw(_ rect: CGRect) {
		drawKeyboard(rect)
		
		if isShowingFrames {
			UIColor.yellow.setStroke()
			for (rect, _) in scaledRects {
				UIBezierPath(rect: rect).stroke()
			}
		}
		
		if isShowingTaps {
			UIColor.pressedElementOverlay.setFill()
			for rect in pressedKeyRects {
				UIBezierPath(rect: rect).fill()
			}
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			if let (code, rect) = keyData(for: location) {
				pressedKeyCodes.append(code)
				pressedKeyRects.append(rect)
				
				inject(code: code, pressed: true)
				
				if isShowingTaps {
					setNeedsDisplay()
				}
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let previouslyPressed = pressedKeyCodes
		pressedKeyCodes.removeAll()
		pressedKeyRects.removeAll()
		
		for touch in touches {
			let location = touch.location(in: self)
			if let (code, rect) = keyData(for: location) {
				pressedKeyCodes.append(code)
				pressedKeyRects.append(rect)
			}
		}

		// Report all keys that got depressed from last time.
		previouslyPressed.filter { !pressedKeyCodes.contains($0) }.forEach { code in
			inject(code: code, pressed: false)
			if isShowingTaps {
				setNeedsDisplay()
			}
		}
		
		// Reports all newly pressed keys.
		pressedKeyCodes.filter { !previouslyPressed.contains($0) }.forEach { code in
			inject(code: code, pressed: true)
			if isShowingTaps {
				setNeedsDisplay()
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			if let (code, _) = keyData(for: location) {
				if let idx = pressedKeyCodes.index(of: code) {
					pressedKeyCodes.remove(at: idx)
					pressedKeyRects.remove(at: idx)
				}
				
				inject(code: code, pressed: false)
				
				if isShowingTaps {
					setNeedsDisplay()
				}
			}
		}
	}
	
	// MARK: - Overidable functions
	
	func drawKeyboard(_ rect: CGRect) {
		fatalError("Subclass must override to draw the keyboard!")
	}
}

// MARK: - Subclass functions

extension BaseKeyboardView {
	
	/**
	Configures the view with the given unscaled keyboard rect.
	*/
	func configure(unscaledKeyboardRect rect: CGRect) {
		unscaledKeyboardRect = rect
	}
	
	/**
	Configures the view with the given unscaled key rects.
	*/
	func configure(unscaledKeyRects rects: [CGRect: KeyCode]) {
		unscaledKeyRects = rects
	}
}

// MARK: - Helper functions

extension BaseKeyboardView {
	
	/**
	Injects the given key code to fuse.
	*/
	fileprivate func inject(code: KeyCode, pressed: Bool) {
		if pressed {
			Feedback.produce()
		}
		code.inject(pressed: pressed)
	}
	
	/**
	Returns the input key corresponding to given point, or nil if none.
	*/
	fileprivate func keyData(for point: CGPoint) -> (KeyCode, CGRect)? {
		for (rect, state) in scaledRects {
			if rect.contains(point) {
				return (state, rect)
			}
		}
		return nil
	}
	
	/**
	Updates scaled rects dictionary.
	*/
	fileprivate func updateScaledRects() {
		let scaler = CGRect.scaler(from: unscaledKeyboardRect, to: bounds, mode: renderMode)
		var rects = [CGRect: KeyCode]()
		for (rect, code) in unscaledKeyRects {
			let scaled = scaler.scaled(rect: rect)
			rects[scaled] = code
		}
		scaledRects = rects
	}
}

// MARK: - Signals handling

extension BaseKeyboardView {
	
	fileprivate func setupKeyboardModeUserDefaultSignal() {
		UserDefaults.standard.reactive.keyboardRenderingModeSignal.distinct().bind(to: self) { me, value in
			gverbose("Updating rendering mode to \(value)")
			me.renderMode = value
		}
	}
}
