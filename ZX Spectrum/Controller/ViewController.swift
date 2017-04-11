//
//  Created by Tomaz Kragelj on 26.03.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet private weak var spectrumView: SpectrumScreenView!
	
	private var emulator: Emulator!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		emulator = Emulator()!
		
		settings_defaults(&settings_current);
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		spectrumView.hookToFuse()
		fuse_init(0, nil);
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		fuse_end()
		spectrumView.unhookFromFuse()
	}
}

