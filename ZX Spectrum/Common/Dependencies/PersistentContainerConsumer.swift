//
//  Created by Tomaz Kragelj on 23.10.16.
//  Copyright © 2016 Tomaz Kragelj. All rights reserved.
//

import Foundation
import CoreData

protocol PersistentContainerConsumer {
	
	func configure(persistentContainer: NSPersistentContainer)
}

protocol PersistentContainerProvider {
	
	func providePersistentContainer() -> NSPersistentContainer
}
