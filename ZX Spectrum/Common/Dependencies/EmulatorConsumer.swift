//
//  Created by Tomaz Kragelj on 19.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

protocol EmulatorConsumer {
	
	func configure(emulator: Emulator)
}

protocol EmulatorProvider {
	
	func provideEmulator() -> Emulator
}
