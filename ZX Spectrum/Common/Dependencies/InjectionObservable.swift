//
//  Created by Tomaz Kragelj on 8.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

/**
Defines the requirements for injection observer.
*/
protocol InjectionObservable {
	
	/**
	Called after all dependencies are injected.
	*/
	func injectionDidComplete()
}
