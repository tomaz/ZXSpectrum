//
//  Created by Tomaz Kragelj on 8.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Represents joystick thumb view.
*/
final class JoystickStickView: UIView {
	
	/// Maximum distance value that will get reported via `updateIndicator(distance:angle:)`. This is used so that stick is always rendered through its full visible area. For example, if maximum distance reported will be 0.8, then also set this value to 0.8; if you leave it at 1, the stick
	var maximumDistanceRatio = CGFloat(1) {
		didSet {
			updateIndicatorFrame()
		}
	}
	
	// MARK: - Stick handling
	
	fileprivate var indicatorView: JoystickButtonView!
	fileprivate var indicatorRect = CGRect.zero
	fileprivate var indicatorInitialLocation = CGPoint.zero
	fileprivate var indicatorMaxTravel = CGFloat(0)
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
		
		indicatorInitialLocation.x = bounds.midX - indicatorRect.width / 2
		indicatorInitialLocation.y = bounds.midY - indicatorRect.height / 2
		
		indicatorMaxTravel = (size - indicatorRect.width) / 2
		
		updateIndicatorFrame()
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
		updateIndicatorFrame()
	}
	
	fileprivate func updateIndicatorFrame() {
		var distance = indicatorDistance
		
		if maximumDistanceRatio != 1 {
			distance /= maximumDistanceRatio
			if distance > 1 {
				distance = 1
			}
		}
		
		indicatorRect.origin.x = indicatorInitialLocation.x + indicatorMaxTravel * distance * cos(indicatorAngle)
		indicatorRect.origin.y = indicatorInitialLocation.y + indicatorMaxTravel * distance * sin(indicatorAngle)
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
