//
//  Created by Tomaz Kragelj on 8.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

typealias JoystickKeyCodeSelectionHandler = ([KeyCode]?) -> Void

protocol JoystickKeyCodeSelectionHandlerConsumer {

	func configure(selectionChangeHandler: @escaping JoystickKeyCodeSelectionHandler)
}

protocol JoystickKeyCodeSelectionHandlerProvider {
	
	func provideSelectionChangeHandler() -> JoystickKeyCodeSelectionHandler
}
