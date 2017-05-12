//
//  Created by Tomaz Kragelj on 12.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Manages keyboard input for ZX 128K Spectrum
*/
final class ZX128KeyboardView: BaseKeyboardView {
	
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
		backgroundColor = ZX128KeyboardStyleKit.keyboardBackgroundColor
		configure(unscaledKeyboardRect: ZX128KeyboardView.keyboardRect)
		configure(unscaledKeyRects: ZX128KeyboardView.keyRects)
	}
	
	// MARK: - Overriden functions
	
	override func draw(_ rect: CGRect) {
		ZX128KeyboardStyleKit.drawKeyboard(frame: bounds, resizing: .aspectFit)
		
		super.draw(rect)
	}
}

// MARK: - Constants

extension ZX128KeyboardView {

	/// Raw size of the keyboard.
	fileprivate static let keyboardRect = CGRect(x: 0, y: 0, width: 2048, height: 756)
	
	/// Raw rects and their corresponding input key.
	fileprivate static let keyRects: [CGRect: KeyCode] = [
		CGRect(x: 0, y: 2, width: 146, height: 142): .trueVideo,
		CGRect(x: 153, y: 2, width: 146, height: 142): .inverseVideo,
		
		CGRect(x: 304, y: 2, width: 146, height: 142): .num1,
		CGRect(x: 455, y: 2, width: 146, height: 142): .num2,
		CGRect(x: 606, y: 2, width: 146, height: 142): .num3,
		CGRect(x: 758, y: 2, width: 146, height: 142): .num4,
		CGRect(x: 911, y: 2, width: 146, height: 142): .num5,
		CGRect(x: 1062, y: 2, width: 146, height: 142): .num6,
		CGRect(x: 1215, y: 2, width: 146, height: 142): .num7,
		CGRect(x: 1367, y: 2, width: 146, height: 142): .num8,
		CGRect(x: 1518, y: 2, width: 146, height: 142): .num9,
		CGRect(x: 1671, y: 2, width: 146, height: 142): .num0,
		CGRect(x: 1822, y: 2, width: 218, height: 142): .brk,
		
		CGRect(x: 1, y: 154, width: 221, height: 142): .delete,
		CGRect(x: 381, y: 154, width: 146, height: 142): .q,
		CGRect(x: 533, y: 154, width: 146, height: 142): .w,
		CGRect(x: 685, y: 154, width: 146, height: 142): .e,
		CGRect(x: 837, y: 154, width: 146, height: 142): .r,
		CGRect(x: 989, y: 154, width: 146, height: 142): .t,
		CGRect(x: 1141, y: 154, width: 146, height: 142): .y,
		CGRect(x: 1293, y: 154, width: 146, height: 142): .u,
		CGRect(x: 1444, y: 154, width: 146, height: 142): .i,
		CGRect(x: 1595, y: 154, width: 146, height: 142): .o,
		CGRect(x: 1747, y: 154, width: 146, height: 142): .p,
		
		CGRect(x: 229, y: 306, width: 183, height: 142): .edit,
		CGRect(x: 418, y: 305, width: 146, height: 142): .a,
		CGRect(x: 570, y: 305, width: 146, height: 142): .s,
		CGRect(x: 722, y: 305, width: 146, height: 142): .d,
		CGRect(x: 874, y: 305, width: 146, height: 142): .f,
		CGRect(x: 1026, y: 305, width: 146, height: 142): .g,
		CGRect(x: 1178, y: 305, width: 146, height: 142): .h,
		CGRect(x: 1330, y: 305, width: 146, height: 142): .j,
		CGRect(x: 1482, y: 305, width: 146, height: 142): .k,
		CGRect(x: 1634, y: 305, width: 146, height: 142): .l,
		
		CGRect(x: 2, y: 457, width: 335, height: 142): .capsShift,
		CGRect(x: 496, y: 458, width: 146, height: 142): .z,
		CGRect(x: 647, y: 458, width: 146, height: 142): .x,
		CGRect(x: 800, y: 458, width: 146, height: 142): .c,
		CGRect(x: 952, y: 458, width: 146, height: 142): .v,
		CGRect(x: 1103, y: 458, width: 146, height: 142): .b,
		CGRect(x: 1255, y: 458, width: 146, height: 142): .n,
		CGRect(x: 1406, y: 458, width: 146, height: 142): .m,
		CGRect(x: 1746, y: 611, width: 146, height: 142): .period,
		CGRect(x: 1710, y: 458, width: 335, height: 142): .capsShift,
		
		CGRect(x: 0, y: 611, width: 146, height: 142): .symbolShift,
		CGRect(x: 153, y: 611, width: 146, height: 142): .semicolon,
		CGRect(x: 306, y: 611, width: 146, height: 142): .doubleQuote,
		CGRect(x: 458, y: 611, width: 146, height: 142): .left,
		CGRect(x: 610, y: 611, width: 146, height: 142): .right,
		CGRect(x: 762, y: 611, width: 673, height: 142): .space,
		CGRect(x: 1442, y: 611, width: 146, height: 142): .up,
		CGRect(x: 1593, y: 611, width: 146, height: 142): .down,
		CGRect(x: 1558, y: 458, width: 146, height: 142): .comma,
		CGRect(x: 1898, y: 611, width: 146, height: 142): .symbolShift,
		
		CGRect(x: 1786, y: 303, width: 257, height: 144): .enter,
		CGRect(x: 1902, y: 152, width: 144, height: 151): .enter,
	]
}
