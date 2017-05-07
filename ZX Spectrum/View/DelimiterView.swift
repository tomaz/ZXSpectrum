//
//  Created by Tomaz Kragelj on 6.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Vertical delimiter view.
*/
class DelimiterView: UIView {
	
	/// Delimiter height, or 0 for default.
	@IBInspectable var delimiterHeight: CGFloat = 0
	
	private lazy var delimiterColor = UIColor(white: 0.9, alpha: 1)
	private lazy var path = UIBezierPath()
	
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
		backgroundColor = UIColor.clear
	}
	
	// MARK: - Overriden functions
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIViewNoIntrinsicMetric, height: delimiterHeight > 0 ? delimiterHeight : 10)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: bounds.midY))
		path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
	}
	
	override func draw(_ rect: CGRect) {
		delimiterColor.setStroke()
		path.stroke()
	}
}
