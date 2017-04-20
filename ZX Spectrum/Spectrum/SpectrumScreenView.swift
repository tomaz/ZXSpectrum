//
//  Created by Tomaz Kragelj on 6.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class SpectrumScreenView: UIView {
	
	/// Current palette.
	fileprivate lazy var palette = SpectrumPalette.colored
	
	/// Input view.
	fileprivate lazy var keyboardView = ZX48KeyboardView()
	
	/// Display controller middleware between UI C API and view.
	fileprivate lazy var displayController = SpectrumDisplayController()
	
	// MARK: - Subviews
	
	fileprivate var imageView: UIImageView!
	
	// MARK: - Initialization & disposal
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializeView()
	}
	
	private func initializeView() {
		imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(imageView)
		
		imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
	
	// MARK: - Overriden functions
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	override var inputView: UIView? {
		return keyboardView
	}
}

// MARK: - UIKeyInput

extension SpectrumScreenView: UIKeyInput {
	
	var hasText: Bool {
		return true
	}
	
	func insertText(_ text: String) {
	}
	
	func deleteBackward() {
	}
}

// MARK: - Hooking and unhooking

extension SpectrumScreenView {
	
	/**
	Hooks to underlying fuse display callbacks.
	*/
	func hookToFuse() {
		displayController.handler = self
	}
	
	/**
	Unhooks from underlying fuse display callbacks.
	*/
	func unhookFromFuse() {
		displayController.handler = nil
	}
}

// MARK: - Fuse integration

extension SpectrumScreenView: SpectrumDisplayHandler {
	
	func spectrumDisplayController(_ controller: SpectrumDisplayController, renderImage image: UIImage) {
		onMain {
			self.imageView.image = image
		}
	}
}
