//
//  Created by Tomaz Kragelj on 19.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
	
	/**
	Saves the context and in case of error presents it in the given responder.
	*/
	func savePresentingError() {
		do {
			try save()
		} catch {
			UIViewController.current.present(error: error as NSError)
		}
	}
}

