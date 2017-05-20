//
//  ZX128KeyboardStyleKit.swift
//  ZX Spectrum Emulator
//
//  Created by Tomaz Kragelj on 12.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

public class ZX128KeyboardStyleKit : NSObject {

    //// Cache

    private struct Cache {
        static let keyboardBackgroundColor: UIColor = UIColor(red: 0.176, green: 0.176, blue: 0.176, alpha: 1.000)
    }

    //// Colors

    public dynamic class var keyboardBackgroundColor: UIColor { return Cache.keyboardBackgroundColor }

    //// Drawing Methods

    public dynamic class func drawKeyboard(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 2048, height: 756), resizing: ResizingBehavior = .aspectFit, smallFontSize: CGFloat = 24.5, mainFontSize: CGFloat = 40, shiftFontSize: CGFloat = 32) {
	}
	
	@objc(ZX128KeyboardStyleKitResizingBehavior)
	public enum ResizingBehavior: Int {
		case aspectFit /// The content is proportionally resized to fit into the target rectangle.
		case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
		case stretch /// The content is stretched to match the entire target rectangle.
		case center /// The content is centered in the target rectangle, but it is NOT resized.
		
		public func apply(rect: CGRect, target: CGRect) -> CGRect {
			if rect == target || target == CGRect.zero {
				return rect
			}
			
			var scales = CGSize.zero
			scales.width = abs(target.width / rect.width)
			scales.height = abs(target.height / rect.height)
			
			switch self {
			case .aspectFit:
				scales.width = min(scales.width, scales.height)
				scales.height = scales.width
			case .aspectFill:
				scales.width = max(scales.width, scales.height)
				scales.height = scales.width
			case .stretch:
				break
			case .center:
				scales.width = 1
				scales.height = 1
			}
			
			var result = rect.standardized
			result.size.width *= scales.width
			result.size.height *= scales.height
			result.origin.x = target.minX + (target.width - result.width) / 2
			result.origin.y = target.minY + (target.height - result.height) / 2
			return result
		}
	}
}
