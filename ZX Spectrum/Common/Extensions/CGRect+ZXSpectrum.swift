//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension CGRect {

	/**
	Returns scaled rectangle to fit within the given target.
	
	Note if you intend to reuse the same scaling for many operations, you might want to use `scaler(from:to:)` instead.
	
	@param source Source rectangle defining the area this instance is measured against.
	@param target Target rectangle within which this instance needs to be scaled.
	@return Scaled rectangle.
	*/
	func scaled(from source: CGRect, to target: CGRect) -> CGRect {
		return Scaler(from: source, to: target).scaled(rect: self)
	}
	
	/**
	Returns scaler that knows how to scale rects to fit within the given target.
	
	This is optimized `scaled(from:to:)` variant; it performs initial calculations only once and then applies scale to any given rect. It's advised to be used in loops and other places where a lot of scaling within the same source and target rects are needed.
	
	@param source Source rectangle defining the area this instance is measured against.
	@param target Target rectangle within which this instance needs to be scaled.
	@return Scaler for scaling the rectangles.
	*/
	static func scaler(from source: CGRect, to target: CGRect) -> Scaler {
		return Scaler(from: source, to: target)
	}
	
	class Scaler {
		private let scale: CGFloat
		private let offset: CGPoint
		
		fileprivate init(from source: CGRect, to target: CGRect) {
			let scales = CGSize(
				width: abs(target.width / source.width),
				height: abs(target.height / source.height))
			
			scale = min(scales.width, scales.height)
			
			offset = CGPoint(
				x: target.minX + (target.width - source.width * scale) / 2,
				y: target.minY + (target.height - source.height * scale) / 2)
		}
		
		func scaled(rect: CGRect) -> CGRect {
			let scaledWidth = rect.width * scale
			let scaledHeight = rect.height * scale
			
			return CGRect(
				x: offset.x + rect.minX * scale,
				y: offset.y + rect.minY * scale,
				width: scaledWidth,
				height: scaledHeight)
		}
	}
}

extension CGRect: Hashable {
	
	public var hashValue: Int {
		return minX.hashValue ^ Int(minY).hashValue ^ Int(width).hashValue ^ Int(height).hashValue
	}
}

extension CGPoint {
	
	/**
	Returns distance to the given point.
	*/
	func distance(to: CGPoint) -> CGFloat {
		let dx = x - to.x
		let dy = y - to.y
		return sqrt((dx * dx) + (dy * dy))
	}
	
	/**
	Returns angle in radians to the given point.
	*/
	func angle(to: CGPoint) -> CGFloat {
		let dx = x - to.x
		let dy = y - to.y
		return atan2(dy, dx)
	}
}
