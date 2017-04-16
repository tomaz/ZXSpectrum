//
//  Created by Tomaz Kragelj on 16.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

extension UIGestureRecognizer {
	
	typealias ActionType = (UIGestureRecognizer) -> Void
	
	convenience init(handler: @escaping ActionType) {
		self.init()
		recognizerAction = handler
		addTarget(self, action: #selector(handle(recognizer:)))
	}
	
	@objc private func handle(recognizer: UIGestureRecognizer) {
		recognizerAction?(self)
	}
	
	private var recognizerAction: ActionType? {
		get { return objc_getAssociatedObject(self, &UIGestureRecognizer.AssociatedKeys.RecognizerActionKey) as? ActionType }
		set { objc_setAssociatedObject(self, &UIGestureRecognizer.AssociatedKeys.RecognizerActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
	private struct AssociatedKeys {
		static var RecognizerActionKey = "RecognizerActionKey"
	}
}
