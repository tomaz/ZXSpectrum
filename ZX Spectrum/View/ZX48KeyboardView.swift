//
//  Created by Tomaz Kragelj on 13.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Managed keyboard input for ZX 48K Spectrum
*/
class ZX48KeyboardView: BaseKeyboardView {
	
	/// Indicates whether the view shows user taps (leave false for better performance).
	var isShowingTaps = false
	
	/// Scaled rects for every key.
	fileprivate lazy var scaledRects = [CGRect: KeyCode]()
	
	/// Currently pressed key codes.
	fileprivate lazy var pressedKeyCodes = [KeyCode]()
	
	/// Currently pressed key rects.
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
		backgroundColor = ZX48KeyboardStyleKit.keyboardBackgroundColor
	}
	
	// MARK: - Overriden functions
	
	override func layoutSubviews() {
		super.layoutSubviews()
		updateScaledRects()
	}
	
	override func draw(_ rect: CGRect) {
		ZX48KeyboardStyleKit.drawKeyboard(frame: bounds, resizing: .aspectFit)

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
				send(key: code, pressed: true)
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
			send(key: code, pressed: false)
			if isShowingTaps {
				setNeedsDisplay()
			}
		}
		
		// Reports all newly pressed keys.
		pressedKeyCodes.filter { !previouslyPressed.contains($0) }.forEach { code in
			send(key: code, pressed: true)
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
				send(key: code, pressed: false)
				if isShowingTaps {
					setNeedsDisplay()
				}
			}
		}
	}
}

// MARK: - Helper functions

extension ZX48KeyboardView {
	
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
		let scaler = CGRect.scaler(from: ZX48KeyboardView.keyboardRect, to: bounds)
		var rects = [CGRect: KeyCode]()
		for (rect, code) in ZX48KeyboardView.keyRects {
			let scaled = scaler.scaled(rect: rect)
			rects[scaled] = code
		}
		scaledRects = rects
	}
}

// MARK: - Constants

extension ZX48KeyboardView {

	/// Raw size of the keyboard.
	fileprivate static let keyboardRect = CGRect(x: 0, y: 0, width: 2601, height: 968)
	
	/// Raw rects and their corresponding input key.
	fileprivate static let keyRects: [CGRect: KeyCode] = [
		CGRect(x: 34, y: 16, width: 188, height: 238): .num1,
		CGRect(x: 273, y: 16, width: 188, height: 238): .num2,
		CGRect(x: 514, y: 16, width: 188, height: 238): .num3,
		CGRect(x: 754, y: 16, width: 188, height: 238): .num4,
		CGRect(x: 995, y: 16, width: 188, height: 238): .num5,
		CGRect(x: 1235, y: 16, width: 188, height: 238): .num6,
		CGRect(x: 1475, y: 16, width: 188, height: 238): .num7,
		CGRect(x: 1716, y: 16, width: 188, height: 238): .num8,
		CGRect(x: 1957, y: 16, width: 188, height: 238): .num9,
		CGRect(x: 2197, y: 16, width: 188, height: 238): .num0,
		
		CGRect(x: 155, y: 284, width: 188, height: 203): .q,
		CGRect(x: 395, y: 284, width: 188, height: 203): .w,
		CGRect(x: 635, y: 284, width: 188, height: 203): .e,
		CGRect(x: 876, y: 284, width: 188, height: 203): .r,
		CGRect(x: 1116, y: 284, width: 188, height: 203): .t,
		CGRect(x: 1356, y: 284, width: 188, height: 203): .y,
		CGRect(x: 1595, y: 284, width: 188, height: 203): .u,
		CGRect(x: 1837, y: 284, width: 188, height: 203): .i,
		CGRect(x: 2076, y: 284, width: 188, height: 203): .o,
		CGRect(x: 2317, y: 284, width: 188, height: 203): .p,
		
		CGRect(x: 214, y: 520, width: 188, height: 203): .a,
		CGRect(x: 454, y: 520, width: 188, height: 203): .s,
		CGRect(x: 694, y: 520, width: 188, height: 203): .d,
		CGRect(x: 935, y: 520, width: 188, height: 203): .f,
		CGRect(x: 1175, y: 520, width: 188, height: 203): .g,
		CGRect(x: 1415, y: 520, width: 188, height: 203): .h,
		CGRect(x: 1655, y: 520, width: 188, height: 203): .j,
		CGRect(x: 1896, y: 520, width: 188, height: 203): .k,
		CGRect(x: 2135, y: 520, width: 188, height: 203): .l,
		CGRect(x: 2376, y: 520, width: 188, height: 203): .enter,
		
		CGRect(x: 35, y: 756, width: 245, height: 203): .capsShift,
		CGRect(x: 332, y: 756, width: 188, height: 203): .z,
		CGRect(x: 572, y: 756, width: 188, height: 203): .x,
		CGRect(x: 813, y: 756, width: 188, height: 203): .c,
		CGRect(x: 1053, y: 756, width: 188, height: 203): .v,
		CGRect(x: 1293, y: 756, width: 188, height: 203): .b,
		CGRect(x: 1533, y: 756, width: 188, height: 203): .n,
		CGRect(x: 1774, y: 756, width: 188, height: 203): .m,
		CGRect(x: 2013, y: 756, width: 188, height: 203): .symbolShift,
		CGRect(x: 2254, y: 756, width: 307, height: 203): .space,
	]
}
