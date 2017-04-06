//
//  ViewController.swift
//  ZX Spectrum
//
//  Created by Tomaz Kragelj on 26.03.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	private var emulator: Emulator!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		SpectrumScreenView.hookToFuse()
		
		emulator = Emulator()!
		
		settings_defaults(&settings_current);

		fuse_init(0, nil);
		
//		while true {
//			RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)
//		}
	}
}

