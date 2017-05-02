//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation
import CoreData
import ReactiveKit

/**
Various non-persistent defaults.
*/
class Defaults {
	
	/// If true, we should show joystick for input method, otherwise keyboard.
	static let isInputJoystick = Property<Bool>(false)
	
	/// Current object IS; this is nil when no file is selected.
	static let currentObjectID = Property<NSManagedObjectID?>(nil)
}
