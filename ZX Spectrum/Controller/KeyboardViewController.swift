//
//  Created by Tomaz Kragelj on 11.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
ZX 48K style keyboard.
*/
final class KeyboardViewController: UIViewController {

	// MARK: - Initialization & disposal
	
	/**
	Creates and returns new instance.
	*/
	static func instantiate() -> KeyboardViewController {
		let storyboard = UIViewController.current.storyboard!
		return storyboard.instantiateViewController(withIdentifier: "ZX48Scene") as! KeyboardViewController
	}
}
