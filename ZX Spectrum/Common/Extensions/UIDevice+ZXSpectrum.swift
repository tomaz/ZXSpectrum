//
//  Created by Tomaz Kragelj on 8.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

extension UIDevice {
	
	/// Specifies whether current device is an iPad type.
	static var iPad: Bool {
		return UIDevice.current.userInterfaceIdiom == .pad
	}
	
	/// Specifies whether current device is an iPhone type.
	static var iPhone: Bool {
		return UIDevice.current.userInterfaceIdiom == .phone
	}
}
