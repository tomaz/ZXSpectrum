//
//  Created by Tomaz Kragelj on 8.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Represents joystick thumb view.
*/
final class JoystickStickView: UIView {
	
	/// Maximum distance value that will get reported. This is used so that stick always renders in full area.
	var maximumDistance = CGFloat(1) {
		didSet {
			updateMaxiumOffset()
		}
	}
	
	// MARK: - Stick handling
	
	fileprivate var indicatorView: JoystickButtonView!
	fileprivate var indicatorCenter = CGPoint.zero
	fileprivate var indicatorMaxOffset = CGPoint.zero
	fileprivate var indicatorRect = CGRect.zero
	fileprivate var indicatorAngle = CGFloat(0)
	fileprivate var indicatorDistance = CGFloat(0)
	
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
		backgroundColor = UIColor.clear
		
		indicatorView = JoystickButtonView(frame: CGRect.zero)
		indicatorView.isLarge = true
		
		addSubview(indicatorView)
	}
	
	// MARK: - Overriden functions
	
	override var intrinsicContentSize: CGSize {
		return JoystickStickView.viewSize
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let size = min(bounds.width, bounds.height)
		indicatorRect.size.width = size * JoystickStickView.indicatorRatio.width
		indicatorRect.size.height = size * JoystickStickView.indicatorRatio.height
		
		indicatorCenter.x = bounds.midX - indicatorRect.width / 2
		indicatorCenter.y = bounds.midY - indicatorRect.height / 2
		
		indicatorMaxOffset.x = (size - indicatorRect.width) / 2
		indicatorMaxOffset.y = (size - indicatorRect.height) / 2
		
		updateMaxiumOffset()
		updateIndicatorPosition()
	}
	
	override func draw(_ rect: CGRect) {
		JoystickStyleKit.drawJoystickBackground(frame: bounds)
	}
}

// MARK: - Helper functions

extension JoystickStickView {
	
	/**
	Updates indicator view for the given distance and angle.
	*/
	func updateIndicator(distance: CGFloat, angle: CGFloat) {
		indicatorDistance = distance
		indicatorAngle = angle
		updateIndicatorPosition()
	}
	
	fileprivate func updateMaxiumOffset() {
		// Take into account maximum distance.
		if maximumDistance > 0 {
			indicatorMaxOffset.x *= 1 / maximumDistance
			indicatorMaxOffset.y *= 1 / maximumDistance
		}
	}
	
	fileprivate func updateIndicatorPosition() {
		indicatorRect.origin.x = indicatorCenter.x + indicatorMaxOffset.x * indicatorDistance * cos(indicatorAngle)
		indicatorRect.origin.y = indicatorCenter.y + indicatorMaxOffset.y * indicatorDistance * sin(indicatorAngle)
		indicatorView.frame = indicatorRect
	}
}

// MARK: - Constants

extension JoystickStickView {
	
	fileprivate static let viewSize = CGSize(width: 250, height: 250)
	fileprivate static let indicatorSize = CGSize(width: 160, height: 160)
	fileprivate static let indicatorRatio = CGSize(
		width: indicatorSize.width / viewSize.width,
		height: indicatorSize.height / viewSize.height)
}
