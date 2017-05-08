//
//  Created by Tomaz Kragelj on 9.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
The view that handles and reports touches.

The view works in various modes. You select the mode simply by assigning the desired feedback closure (note closures have precedence, only most important will be used if more than one is assigned):

- The simplest usage is to add subviews and assign `didGetTouchOnSubview` closure. The view will call the closure as touches change, reporting subview that is under the touch. If you want to use subviews but don't want this handling, just leave closure to nil. Note if we only have single `UIStackView` subview, its subviews are taken automatically!

- If subviews handling doesn't work for you, use direct reporting instead via `didMoveFromStartingTouch` closure. This gets called only if `didGetTouchOnSubview` is not assigned. Note you sould not allow multiple touches when using this mode.

Note by default the view only tracks single touch, if you want to suuport multiple touches, set `isMultipleTouchEnabled` to true.
*/
final class TouchableView: UIView {
	
	// MARK: - Relative touches handling
	
	/// Called when touch moves from starting touch. The parameters are: angle in radians (0 = right) and distance in range 0..1 where 0 is center and 1 is offset from center. If touches are released, distance is 0. In such case you can ignore angle.
	var didMoveFromStartingTouch: ((CGFloat, CGFloat) -> Void)?
	
	/// Distance in radians touch must differ from previous angle in order to report it. Greater the number, less frequently changes will be reported, so more optimal, but less precise behavior. Defaults to 1º.
	var touchDetectionAngleThreshold = CGFloat(Direction.radians(1))
	
	/// Optional allowed angles. If provided, current angle is "trimmed" to the closest angle from the given array.
	var trimToAngles: [CGFloat]?
	
	/// Distance touches must travel from previous in order to report it. Greater the number, less frequently changes will be reported, so more optimal, but less precise behavior.
	var touchDetectionDistanceThreshold = CGFloat(1)
	
	/// Threshold from starting touch that defines the point where touch is considered "on". Note: this is ratio, not distance in points, the value of 0 represents no threshold; any movement is considered on, value of 1 represents maximum distance; no touch will be considered on.
	var touchDetectionMinimumThreshold = CGFloat(0) {
		didSet {
			updateDistances()
		}
	}
	
	/// Threshold from starting touch that defines maximum point considered for reporting. Note: this is ratio, not distance in points, the value of 1 represents full view size. You should always keep this value above `touchDetectionMinimumThreshold` otherwise results are undefined.
	var touchDetectionMaximumThreshold = CGFloat(1) {
		didSet {
			updateDistances()
		}
	}
	
	/// Maximum distance for reporting, anything above this is automatically treated as "on".
	fileprivate var maximumDistance = CGFloat(0)
	
	/// Distance threshold in points; touch is only considered pressed if above this distance.
	fileprivate var minimumDistance = CGFloat(0)

	/// Full available distance for touch.
	fileprivate var fullDistance = CGFloat(0)
	
	/// Last reported angle.
	fileprivate var lastAngle = CGFloat(0)
	
	/// Last reported distance.
	fileprivate var lastDistance = CGFloat(0)
	
	/// The coordinate of the first touch in current session (reset when touches get released).
	fileprivate var firstTouch: CGPoint? = nil
	
	// MARK: - Subviews touches handling
	
	/// Called when touch gets over a subview. This only gets called if there is a change.
	var didGetTouchOnSubview: ((UIView, Bool) -> Void)?
	
	/// Last touched subview or nil if none.
	fileprivate var lastTouchedSubview: UIView?
	
	/// Array of included subviews.
	fileprivate lazy var includedSubviews: [UIView] = {
		self.prepareIncludedSubviews()
	}()
	
	// MARK: - Overriden functions
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		updateDistances()
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if didGetTouchOnSubview != nil {
			handleSubviews(touches: touches, pressed: true)
		} else if didMoveFromStartingTouch != nil {
			handleRelative(touches: touches, pressed: true)
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if didGetTouchOnSubview != nil {
			handleSubviews(touches: touches, pressed: true)
		} else if didMoveFromStartingTouch != nil {
			handleRelative(touches: touches, pressed: true)
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if didGetTouchOnSubview != nil {
			handleSubviews(touches: touches, pressed: false)
		} else if didMoveFromStartingTouch != nil {
			handleRelative(touches: touches, pressed: false)
		}
	}
}

// MARK: - Relative touch handling

extension TouchableView {
	
	/**
	Handles relative touches.
	*/
	fileprivate func handleRelative(touches: Set<UITouch>, pressed: Bool) {
		if pressed {
			// For the moment we only handle single location.
			if let location = touches.map({ $0.location(in: self) }).first {
				// If we don't have first touch yet, remember it.
				if firstTouch == nil {
					firstTouch = location
					
					// Reset last angle and distance.
					lastAngle = 0
					lastDistance = 0
					
					// If threshold is greater than 0, just return (we only report touch outside threshold so we need to wait until touch moves).
					if touchDetectionMinimumThreshold > 0 {
						return
					}
				}
				
				// Determine new angle and distance from original touch.
				let distance = location.distance(to: firstTouch!)
				var angle = location.angle(to: firstTouch!)
				
				// Trim angle to allowed angles array.
				if let trimToAngles = trimToAngles, !trimToAngles.isEmpty {
					var closestAngle = angle
					var closestDistance = CGFloat.greatestFiniteMagnitude
					for allowedAngle in trimToAngles {
						let angleDistance = abs(allowedAngle - angle)
						if angleDistance < closestDistance {
							closestDistance = angleDistance
							closestAngle = allowedAngle
						}
					}
					angle = closestAngle
				}
				
				// If distance is below on/off threshold, report change to off if we previously reported on value, otherwise just ignore it. Note we don't wait for touch change detection threshold to report this, it takes greater precedence.
				if distance < minimumDistance {
					if lastDistance >= minimumDistance {
						lastAngle = angle
						lastDistance = 0
						didMoveFromStartingTouch?(angle, 0)
					}
					return
				}
				
				// If we come above on/off threshold, report change to on if we previously reported off value.
				if distance >= minimumDistance && lastDistance == 0 {
					lastAngle = angle
					lastDistance = distance
					didMoveFromStartingTouch?(angle, distance / fullDistance)
					return
				}
				
				// If we reach beyon maximum distance, report last change if needed. From then on, only report if angle changes enough.
				let angleDifferenceFromLastReport = abs(lastAngle - angle)
				if distance >= maximumDistance {
					if lastDistance < maximumDistance || angleDifferenceFromLastReport >= touchDetectionAngleThreshold {
						lastAngle = angle
						lastDistance = distance
						didMoveFromStartingTouch?(angle, maximumDistance / fullDistance)
					}
					return
				}
				
				// If both distance and angle differences are below thresholds, ignore event.
				let distanceDifferenceFromLastReport = abs(lastDistance - distance)
				if angleDifferenceFromLastReport < touchDetectionAngleThreshold && distanceDifferenceFromLastReport < touchDetectionDistanceThreshold {
					return
				}
				
				// Distance is above on/off threshold, so we should report it as on.
				lastAngle = angle
				lastDistance = distance
				didMoveFromStartingTouch?(angle, distance / fullDistance)
			}
		} else {
			// When touches get depressed, reset first touch so we're ready for next time.
			firstTouch = nil
			
			// Report touch off.
			didMoveFromStartingTouch?(lastAngle, 0)
		}
	}
	
	fileprivate func updateDistances() {
		fullDistance = bounds.width / 2
		maximumDistance = fullDistance * touchDetectionMaximumThreshold
		minimumDistance = fullDistance * touchDetectionMinimumThreshold
	}
}

// MARK: - Subviews touch handling

extension TouchableView {
	
	/**
	Handles touches on subviews.
	*/
	fileprivate func handleSubviews(touches: Set<UITouch>, pressed: Bool) {
		if pressed {
			let locations = touches.map { $0.location(in: self) }
			for subview in includedSubviews {
				for location in locations {
					if subview.frame.contains(location) {
						// We have touch over a subview.
						if let previousSubview = lastTouchedSubview {
							// If we have previous touch on one of subviews, only report if it's different subview now.
							if previousSubview !== subview {
								didGetTouchOnSubview?(previousSubview, false)
								lastTouchedSubview = subview
								didGetTouchOnSubview?(subview, true)
							}
						} else {
							// If we don't have previous touch, report this one.
							lastTouchedSubview = subview
							didGetTouchOnSubview?(subview, true)
						}
						return
					}
				}
			}
		}
		
		// If touches ended, or none of subviews was touched, but we have previous touch on a subview, report it now.
		if let previousSubview = lastTouchedSubview {
			lastTouchedSubview = nil
			didGetTouchOnSubview?(previousSubview, false)
		}
	}
	
	fileprivate func prepareIncludedSubviews() -> [UIView] {
		if subviews.count == 1, let stackView = subviews.first as? UIStackView {
			return stackView.subviews
		}
		return subviews
	}
}
