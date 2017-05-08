//
//  Created by Tomaz Kragelj on 8.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Represents joystick button view.
*/
final class JoystickButtonView: UIView {
	
	fileprivate var label: UILabel!
	
	// MARK: - Appearance
	
	/// Specifies whether the button should be large or small.
	@IBInspectable var isLarge: Bool = false {
		didSet {
			label.isHidden = isLarge
			setNeedsDisplay()
			invalidateIntrinsicContentSize()
		}
	}
	
	/// The description text to show.
	var text: String? {
		didSet {
			label.text = text
		}
	}

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
		contentMode = .redraw
		backgroundColor = UIColor.clear
		
		label = UILabel(frame: bounds)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.isHidden = isLarge
		label.textColor = UIColor.white
		
		// Allow label to be enlarged and compressed any time.
		label.setContentHuggingPriority(1, for: .horizontal)
		label.setContentHuggingPriority(1, for: .vertical)
		label.setContentCompressionResistancePriority(1, for: .horizontal)
		label.setContentCompressionResistancePriority(1, for: .vertical)
		
		addSubview(label)
		label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		label.topAnchor.constraint(equalTo: topAnchor).isActive = true
		label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
	
	// MARK: - Overriden functions
	
	override var intrinsicContentSize: CGSize {
		return isLarge ? JoystickButtonView.largeSize : JoystickButtonView.smallSize
	}
	
	override func draw(_ rect: CGRect) {
		if isLarge {
			JoystickStyleKit.drawJoystickButton(frame: bounds)
		} else {
			JoystickStyleKit.drawJoystickSmallButton(frame: bounds)
		}
	}
}

// MARK: - Constants

extension JoystickButtonView {

	fileprivate static let largeSize = CGSize(width: 160, height: 160)
	fileprivate static let smallSize = CGSize(width: 160, height: 75)
}
