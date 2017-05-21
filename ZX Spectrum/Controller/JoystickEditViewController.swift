//
//  Created by Tomaz Kragelj on 6.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData

/**
Manages joystick edit options.
*/
class JoystickEditViewController: UIViewController {
	
	typealias Mapping = JoystickMappingObject.Mapping

	@IBOutlet fileprivate weak var upButton: UIButton!
	@IBOutlet fileprivate weak var downButton: UIButton!
	@IBOutlet fileprivate weak var leftButton: UIButton!
	@IBOutlet fileprivate weak var rightButton: UIButton!
	
	@IBOutlet fileprivate weak var fire1Button: UIButton!
	@IBOutlet fileprivate weak var fire2Button: UIButton!
	@IBOutlet fileprivate weak var fire3Button: UIButton!
	
	@IBOutlet fileprivate weak var unbindButton: UIButton!
	
	// MARK: - Dependencies
	
	fileprivate var persistentContainer: NSPersistentContainer!
	fileprivate var selectionChangeHandler: JoystickKeyCodeSelectionHandler?
	
	// MARK: - Data
	
	fileprivate var file: FileObject!
	fileprivate lazy var mappings: [UIButton: Mapping] = { self.mappingsByMapping() }()
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()

		gdebug("Setting up view")
		setupAccordingCurrentObject()
		setupUnbindButtonTapSignal()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		inject(toController: segue.destination) { me, destination in
			// Handle our custom dependencies; these are only used here so there's no need wasting CPU on every injection
			if let button = sender as? UIButton, let controller = destination as? JoystickBindingViewController, let me = me as? JoystickEditViewController {
				let mapping = me.mappings[button]!
				controller.configure(title: mapping.description)
				controller.configure(selectedKeyCodes: me.file.joystickMapping?.keys(for: mapping))
				controller.configure(selectionChangeHandler: { codes in
					self.update(keyCodes: codes, button: button)
				})
			}
		}
	}
}

// MARK: - Dependencies

extension JoystickEditViewController: PersistentContainerConsumer {
	
	func configure(persistentContainer: NSPersistentContainer) {
		gdebug("Configuring with \(persistentContainer)")
		self.persistentContainer = persistentContainer
	}
}

extension JoystickEditViewController: JoystickKeyCodeSelectionHandlerConsumer {
	
	func configure(selectionChangeHandler: @escaping JoystickKeyCodeSelectionHandler) {
		gdebug("Configurign with selection change handler \(selectionChangeHandler)")
		self.selectionChangeHandler = selectionChangeHandler
	}
}

// MARK: - User interface

extension JoystickEditViewController {
	
	@IBAction func unwindToJoystickEditViewController(segue: UIStoryboardSegue) {
		// This is only used for unbind from binding controller.
	}
}

// MARK: - Helper functions

extension JoystickEditViewController {
	
	fileprivate func setupAccordingCurrentObject() {
		// We should only ever show this controller if file is loaded!
		file = Defaults.currentFile.value!
		
		gverbose("Setting up view for \(file)")
		
		title = NSLocalizedString("Edit \(file.displayName)")

		for (button, mapping) in mappings {
			button.title = KeyCode.description(keys: file.joystickMapping?.keys(for: mapping))
		}
	}
	
	fileprivate func update(keyCodes: [KeyCode]?, button: UIButton) {
		gverbose("Updating button=\(button)")
		
		let context = persistentContainer.viewContext
		let mapping = mappings[button]!
		
		if let codes = keyCodes {
			gverbose("Assigning \(codes) for \(mapping) for \(file)")
			
			// If we don't yet have joystick mapping object assigned, do so now.
			if file.joystickMapping == nil {
				gdebug("Joystick mapping not present, creating one now")
				file.joystickMapping = JoystickMappingObject(context: context)
			}
			
			// Assign the keys.
			file.joystickMapping?.set(keys: codes, for: mappings[button]!)
			
			// Save.
			context.savePresentingError()
			
		} else if let mappingObject = file.joystickMapping {
			gverbose("Deleting mapping for \(mapping) from \(file)")
			mappingObject.set(keys: nil, for: mapping)
			
			// If we removed all codes, also remove joystick mapping object if it's empty now.
			if mappingObject.isEmpty {
				gdebug("Mapping is not empty, deleting it")
				mappingObject.delete()
			}
			
			// Save.
			context.savePresentingError()
		}
		
		// Either case, update button title.
		button.title = KeyCode.description(keys: keyCodes)
		
		// Inform our observer.
		selectionChangeHandler?(keyCodes)
	}
	
	fileprivate func mappingsByMapping() -> [UIButton: Mapping] {
		return [
			self.upButton: .up,
			self.downButton: .down,
			self.leftButton: .left,
			self.rightButton: .right,
			self.fire1Button: .button1,
			self.fire2Button: .button2,
			self.fire3Button: .button3,
		]
	}
}

// MARK: - Signals handling

extension JoystickEditViewController {
	
	fileprivate func setupUnbindButtonTapSignal() {
		unbindButton.reactive.tap.bind(to: self) { me, _ in
			if let mapping = me.file.joystickMapping {
				ginfo("Unbinding all joystick mappings for \(me.file)")
				let context = me.persistentContainer.viewContext
				mapping.delete()
				context.savePresentingError()
				me.setupAccordingCurrentObject()
			}
		}
	}
}
