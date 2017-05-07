//
//  Created by Tomaz Kragelj on 11.03.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

protocol PopoverPresentationConsumer {
	// Nothing to implement, just conform on destination side in order to force popover on iPhone. 
}

extension PopoverPresentationConsumer {
	
	/**
	Presents a controller with given storyboard identifier from the given source view.
	
	Optionally caller can provide configuration closure that's called before presenting controller.
	
	@param storyboardIdentifier View controller identifier
	@param sourceView View from which to present popover
	@param configuration Optional configuration block
	*/
	static func present(storyboardIdentifier: String, from sourceView: UIView, configuration: ((Self) -> Void)? = nil) {
		let current = UIViewController.current
		let controller = current.storyboard!.instantiateViewController(withIdentifier: storyboardIdentifier)
		
		controller.modalPresentationStyle = .popover
		controller.popoverPresentationController?.sourceView = sourceView
		controller.popoverPresentationController?.sourceRect = sourceView.bounds
		
		configuration?(controller as! Self)
		
		current.present(controller, animated: true, completion: nil)
	}
}
