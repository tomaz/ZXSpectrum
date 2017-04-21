//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Represents joystick input view.
*/
final class JoystickView: UIView {

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
}
