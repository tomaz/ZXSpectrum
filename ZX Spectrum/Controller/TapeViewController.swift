//
//  Created by Tomaz Kragelj on 20.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import ReactiveKit
import Bond

/**
Manages tape.
*/
final class TapeViewController: UIViewController {
	
	@IBOutlet fileprivate weak var titleLabel: UILabel!
	
	// MARK: - Initialization & disposal
	
	/**
	Creates and returns new instance.
	*/
	static func instantiate() -> TapeViewController {
		let storyboard = UIViewController.current.storyboard!
		return storyboard.instantiateViewController(withIdentifier: "TapeScene") as! TapeViewController
	}
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()
		
		gdebug("Setting up view")
		setupTitle()
		
		gdebug("Setting up signals")
		setupCurrentObjectSignal()
	}
}

// MARK: - User interface

extension TapeViewController {
	
	fileprivate func setupTitle() {
		titleLabel.attributedText = TapeViewController.titleText(object: Defaults.currentFile.value)
	}
}

// MARK: - Signals handling

extension TapeViewController {
	
	fileprivate func setupCurrentObjectSignal() {
		Defaults.currentFile.bind(to: self) { me, value in
			gverbose("Updating for object ID \(String(describing: value))")
			me.setupTitle()
		}
	}
}

// MARK: - Styling

extension TapeViewController {
	
	fileprivate static func titleText(object: FileObject?) -> NSAttributedString? {
		guard let object = object else {
			return nil
		}
		
		let result = NSMutableAttributedString()
		result.append(object.url.deletingPathExtension().lastPathComponent.uppercased().set(style: titleEmphasizedStyle))
		result.append(".".set(style: titleLightStyle))
		result.append(object.url.pathExtension.set(style: titleLightStyle))
		return result
	}
	
	private static let titleLightStyle = Styles.style(appearance: [ .light, .inverted ], size: .title)
	private static let titleEmphasizedStyle = Styles.style(appearance: [ .emphasized, .inverted ], size: .title)
}
