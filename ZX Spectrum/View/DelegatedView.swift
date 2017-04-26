//
//  Created by Tomaz Kragelj on 26.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
View that delegates drawing to external object.
*/
class DelegatedView: UIView {
	
	typealias RendererType = (CGRect, CGRect) -> Void
	
	/// Renderer closure.
	var renderer: RendererType? = nil {
		didSet {
			setNeedsDisplay()
		}
	}
	
	// MARK: - Initialization & disposal
	
	convenience init(renderer: @escaping RendererType) {
		self.init()
		self.renderer = renderer
	}
	
	// MARK: - Overriden functions

	override func draw(_ rect: CGRect) {
		renderer?(bounds, rect)
	}
}
