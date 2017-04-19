//
//  Created by Tomaz Kragelj on 11.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Toolbar container view.

Use as container for "toolbar" controls; it'll take care of intrinsic content size.
*/
final class ToolbarView: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializeView()
	}
	
	private func initializeView() {
		backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
	}
	
	// MARK: - Overriden functions

	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIViewNoIntrinsicMetric, height: 44)
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: 0))
		path.addLine(to: CGPoint(x: bounds.maxX, y: 0))
		
		UIColor.lightGray.setStroke()
		path.stroke()
	}
}
