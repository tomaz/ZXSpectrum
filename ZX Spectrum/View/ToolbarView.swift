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

	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIViewNoIntrinsicMetric, height: 44)
	}
}
