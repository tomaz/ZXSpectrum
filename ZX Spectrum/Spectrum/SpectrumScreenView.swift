//
//  Created by Tomaz Kragelj on 6.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class SpectrumScreenView: UIView {
	
	/// The requested size of the image.
	fileprivate lazy var imageSize = CGSize.zero
	
	/// Array of bytes for the image; each pixel is represented by 4 bytes - ARGB.
	fileprivate lazy var imageData = [UInt32]()
	
	/// Indicates whether display was updated or not.
	fileprivate lazy var displayUpdated = false
	
	/// Current palette.
	fileprivate lazy var palette = SpectrumPalette.colored
	
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
	
	func spectrumDisplayController(_ controller: SpectrumDisplayController, initSize size: CGSize) -> Bool {
		let length = Int(size.width) * Int(size.height)
		imageData = [UInt32](repeating: UInt32(0), count: length)
		imageSize = size
		return true
	}
	
	func spectrumDisplayController(_ controller: SpectrumDisplayController, drawPixelAt point: CGPoint, scale: CGFloat, color: Int) {
		let addr = address(of: point)
		let raw = palette[color].raw
		
		if scale == 2 {
			imageData[addr] = raw
			imageData[addr + 1] = raw
		} else {
			imageData[addr] = raw
		}
	}
	
	func spectrumDisplayController(_ controller: SpectrumDisplayController, draw8PixelsAt point: CGPoint, scale: CGFloat, data: Int, ink: Int, paper: Int) {
		var addr = address(of: point)
		let inkRaw = palette[ink].raw
		let paperRaw = palette[paper].raw
		
		if scale == 2 {
			imageData[addr] = data & 0x80 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x80 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x40 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x40 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x20 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x20 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x10 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x10 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x08 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x08 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x04 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x04 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x02 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x02 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x01 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x01 > 0 ? inkRaw : paperRaw; addr += 1
		} else {
			imageData[addr] = data & 0x80 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x40 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x20 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x10 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x08 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x04 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x02 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x01 > 0 ? inkRaw : paperRaw; addr += 1
		}
	}
	
	func spectrumDisplayController(_ controller: SpectrumDisplayController, draw16PixelsAt point: CGPoint, scale: CGFloat, data: Int, ink: Int, paper: Int) {
		var addr = address(of: point)
		let inkRaw = palette[ink].raw
		let paperRaw = palette[paper].raw

		for _ in 0..<2 {
			imageData[addr] = data & 0x8000 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x4000 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x2000 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x1000 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0800 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0400 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0200 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0100 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0080 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0040 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0020 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0010 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0008 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0004 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0002 > 0 ? inkRaw : paperRaw; addr += 1
			imageData[addr] = data & 0x0001 > 0 ? inkRaw : paperRaw; addr += 1
		}
	}
	
	func spectrumDisplayController(_ controller: SpectrumDisplayController, updateDisplayAt rect: CGRect) {
		displayUpdated = true
	}
	
	func spectrumDisplayControllerSwapGraphicsMode(_ controller: SpectrumDisplayController) {
		// Nothing to do for now
	}
	
	func spectrumDisplayControllerEndFrame(_ controller: SpectrumDisplayController) {
		if displayUpdated {
			let data = Data(bytes: imageData.toUInt8Array)
			
			if let provider = CGDataProvider(data: data as CFData) {
				let rgbSpace = CGColorSpaceCreateDeviceRGB()
				
				let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
				
				if let cgImage = CGImage(
					width: Int(imageSize.width),
					height: Int(imageSize.height),
					bitsPerComponent: 8,
					bitsPerPixel: 32,
					bytesPerRow: Int(imageSize.width) * 4,
					space: rgbSpace,
					bitmapInfo: info,
					provider: provider,
					decode: nil,
					shouldInterpolate: false,
					intent: .defaultIntent) {
					
					let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
					
					imageView.image = image
				}
			}
			
			displayUpdated = false
		}
	}
	
	func spectrumDisplayControllerEndDisplay(_ controller: SpectrumDisplayController) {
		// Nothing to do for now.
	}
	
	@inline (__always) private func address(of point: CGPoint) -> Int {
		return Int(imageSize.width) * Int(point.y) + Int(point.x)
	}
}
