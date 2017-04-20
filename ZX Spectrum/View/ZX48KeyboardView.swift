//
//  Created by Tomaz Kragelj on 13.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Managed keyboard input for ZX 48K Spectrum
*/
class ZX48KeyboardView: UIView {
	
	typealias KeyCode = keyboard_key_name
	
	/// Specifies whether keyboard uses sticky special keys.
	var isStickySpecials = true
	
	/// Specifies whether caps shift is pressed or not.
	fileprivate var isCapsShiftPressed = false
	
	/// specifies whether symbol shift is pressed or not.
	fileprivate var isSymbolShiftPressed = false
	
	/// Input controller middleware between UIKit events and fuse input.
	fileprivate lazy var inputController = SpectrumInputController()
	
	/// Scaled rects for every key.
	fileprivate lazy var scaledRects = [CGRect: KeyCode]()
	
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
		backgroundColor = ZX48KeyboardStyleKit.keyboardBackgroundColor
		isMultipleTouchEnabled = true
	}
	
	// MARK: - Overriden functions
	
	override func draw(_ rect: CGRect) {
		ZX48KeyboardStyleKit.drawKeyboard(frame: bounds, resizing: .aspectFit)
	}
	
	override var bounds: CGRect {
		didSet {
			updateScaledRects()
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			if let code = keyState(for: location) {
				keyboard_press(code)
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			if let code = keyState(for: location) {
				keyboard_release(code)
			}
		}
	}
}

// MARK: - Helper functions

extension ZX48KeyboardView {
	
	/**
	Returns the input key corresponding to given point, or nil if none.
	*/
	fileprivate func keyState(for point: CGPoint) -> KeyCode? {
		for (rect, state) in scaledRects {
			if rect.contains(point) {
				return state
			}
		}
		return nil
	}
	
	/**
	Updates scaled rects dictionary.
	*/
	fileprivate func updateScaledRects() {
		var rects = [CGRect: KeyCode]()
		for (rect, code) in ZX48KeyboardView.keyRects {
			let scaled = ZX48KeyboardView.rect(from: rect, bounds: bounds)
			rects[scaled] = code
		}
		scaledRects = rects
	}

	/**
	Converts given raw rect into scaled based on given view bounds.
	*/
	private static func rect(from source: CGRect, bounds: CGRect) -> CGRect {
		let scaleX = bounds.width / keyboardSize.width
		let scaleY = bounds.height / keyboardSize.height
		
		let scale = min(scaleX, scaleY)
		
		let offsetX = (bounds.width - keyboardSize.width * scale) / 2.0
		
		let width = source.width * scale
		let height = source.height * scale
		let x = source.minX * scale + offsetX
		let y = source.minY * scale
		
		return CGRect(x: x, y: y, width: width, height: height)
	}
}

// MARK: - Constants

extension ZX48KeyboardView {

	/// Raw size of the keyboard.
	fileprivate static let keyboardSize = CGSize(width: 2601, height: 968)
	
	/// Raw rects and their corresponding input key.
	fileprivate static let keyRects: [CGRect: KeyCode] = [
		CGRect(x: 34, y: 16, width: 188, height: 238): KEYBOARD_1,
		CGRect(x: 273, y: 16, width: 188, height: 238): KEYBOARD_2,
		CGRect(x: 514, y: 16, width: 188, height: 238): KEYBOARD_3,
		CGRect(x: 754, y: 16, width: 188, height: 238): KEYBOARD_4,
		CGRect(x: 995, y: 16, width: 188, height: 238): KEYBOARD_5,
		CGRect(x: 1235, y: 16, width: 188, height: 238): KEYBOARD_6,
		CGRect(x: 1475, y: 16, width: 188, height: 238): KEYBOARD_7,
		CGRect(x: 1716, y: 16, width: 188, height: 238): KEYBOARD_8,
		CGRect(x: 1957, y: 16, width: 188, height: 238): KEYBOARD_9,
		CGRect(x: 2197, y: 16, width: 188, height: 238): KEYBOARD_0,
		
		CGRect(x: 155, y: 284, width: 188, height: 203): KEYBOARD_q,
		CGRect(x: 395, y: 284, width: 188, height: 203): KEYBOARD_w,
		CGRect(x: 635, y: 284, width: 188, height: 203): KEYBOARD_e,
		CGRect(x: 876, y: 284, width: 188, height: 203): KEYBOARD_r,
		CGRect(x: 1116, y: 284, width: 188, height: 203): KEYBOARD_t,
		CGRect(x: 1356, y: 284, width: 188, height: 203): KEYBOARD_y,
		CGRect(x: 1595, y: 284, width: 188, height: 203): KEYBOARD_u,
		CGRect(x: 1837, y: 284, width: 188, height: 203): KEYBOARD_i,
		CGRect(x: 2076, y: 284, width: 188, height: 203): KEYBOARD_o,
		CGRect(x: 2317, y: 284, width: 188, height: 203): KEYBOARD_p,
		
		CGRect(x: 214, y: 520, width: 188, height: 203): KEYBOARD_a,
		CGRect(x: 454, y: 520, width: 188, height: 203): KEYBOARD_s,
		CGRect(x: 694, y: 520, width: 188, height: 203): KEYBOARD_d,
		CGRect(x: 935, y: 520, width: 188, height: 203): KEYBOARD_f,
		CGRect(x: 1175, y: 520, width: 188, height: 203): KEYBOARD_g,
		CGRect(x: 1415, y: 520, width: 188, height: 203): KEYBOARD_h,
		CGRect(x: 1655, y: 520, width: 188, height: 203): KEYBOARD_j,
		CGRect(x: 1896, y: 520, width: 188, height: 203): KEYBOARD_k,
		CGRect(x: 2135, y: 520, width: 188, height: 203): KEYBOARD_l,
		CGRect(x: 2376, y: 520, width: 188, height: 203): KEYBOARD_Enter,
		
		CGRect(x: 35, y: 756, width: 245, height: 203): KEYBOARD_Caps,
		CGRect(x: 332, y: 756, width: 188, height: 203): KEYBOARD_z,
		CGRect(x: 572, y: 756, width: 188, height: 203): KEYBOARD_x,
		CGRect(x: 813, y: 756, width: 188, height: 203): KEYBOARD_c,
		CGRect(x: 1053, y: 756, width: 188, height: 203): KEYBOARD_v,
		CGRect(x: 1293, y: 756, width: 188, height: 203): KEYBOARD_b,
		CGRect(x: 1533, y: 756, width: 188, height: 203): KEYBOARD_n,
		CGRect(x: 1774, y: 756, width: 188, height: 203): KEYBOARD_m,
		CGRect(x: 2013, y: 756, width: 188, height: 203): KEYBOARD_Symbol,
		CGRect(x: 2254, y: 756, width: 307, height: 203): KEYBOARD_space,
	]
}

// MARK: - Extensions

extension CGRect: Hashable {
	
	public var hashValue: Int {
		return minX.hashValue ^ Int(minY).hashValue ^ Int(width).hashValue ^ Int(height).hashValue
	}
}
