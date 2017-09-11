//
//  Created by Tomaz Kragelj on 11.09.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

typealias FileChangeHandler = () -> Void

protocol FileChangeHandlerConsumer {

	func configure(fileChangeHandler: @escaping FileChangeHandler)
}

protocol FileChangeHandlerProvider {
	
	func provideFileChangeHandler() -> FileChangeHandler
}
