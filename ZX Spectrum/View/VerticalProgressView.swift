//
//  Created by Tomaz Kragelj on 25.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Manages vertical progress.
*/
final class VerticalProgressView: UIView {
	
	/**
	Current progress (0..1).
	*/
	var progress: CGFloat = 0 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	// MARK: - Initialization & disposal
	
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
	}
	
	// MARK: - Overriden functions
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		if progress > 0 && progress <= 1 {
			tintColor.setFill()
			UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * progress)).fill()
		}
	}
}
