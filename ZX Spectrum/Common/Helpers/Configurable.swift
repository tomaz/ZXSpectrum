//
//  Created by Tomaz Kragelj on 21.02.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

protocol Configurable {
	associatedtype Data
	
	func configure(object: Data)
}
