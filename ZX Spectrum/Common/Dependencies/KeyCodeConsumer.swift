//
//  Created by Tomaz Kragelj on 2.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

typealias KeyCodeHandler = (KeyCode?) -> Void

protocol KeyCodeConsumer {
	
	func configure(keyCodeHandler: @escaping KeyCodeHandler)
}

protocol KeyCodeProvider {
	
	func provideKeyCodeHandler() -> KeyCodeHandler
}
