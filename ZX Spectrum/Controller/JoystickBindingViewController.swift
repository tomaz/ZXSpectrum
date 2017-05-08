//
//  Created by Tomaz Kragelj on 6.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import Bond

/**
Managed binding for a particular joystick key.
*/
class JoystickBindingViewController: UITableViewController {
	
	@IBOutlet fileprivate weak var unbindBarButtonItem: UIBarButtonItem!
	
	// MARK: - Dependencies
	
	fileprivate var selectionChangeHandler: JoystickKeyCodeSelectionHandler?
	fileprivate var selectedKeyCodes: [KeyCode]!
	
	// MARK: - Data
	
	fileprivate lazy var keys = MutableObservable2DArray<String, KeyCode>([])
	
	// MARK: - Helpers
	
	fileprivate lazy var bond = Bond()
	
	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")

		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		
		gdebug("Binding data")
		keys.bind(to: tableView, using: bond)

		gdebug("Setting up view")
		setupUnbindButtonTapSignal()
		setupTableSelectionSignal()
		updateUnbindButton()

		fetch(animated: false)
	}
}

// MARK: - Dependencies

extension JoystickBindingViewController: JoystickKeyCodeSelectionHandlerConsumer {
	
	func configure(selectionChangeHandler: @escaping JoystickKeyCodeSelectionHandler) {
		gdebug("Configurign with selection change handler \(selectionChangeHandler)")
		self.selectionChangeHandler = selectionChangeHandler
	}
}

extension JoystickBindingViewController {
	
	func configure(title: String?) {
		gdebug("Configuring with title \(String(describing: title))")
		self.title = title
	}
	
	func configure(selectedKeyCodes: [KeyCode]?) {
		gdebug("Configuring with selected key codes \(String(describing: selectedKeyCodes))")
		self.selectedKeyCodes = selectedKeyCodes ?? []
	}
}

// MARK: - Helper functions

extension JoystickBindingViewController {
	
	/**
	Fetches data and updates `keys` with results.
	*/
	fileprivate func fetch(animated: Bool = true) {
		gdebug("Fetching keys")
		let sections = bond.fetch(selected: selectedKeyCodes)
		
		gdebug("Updating with \(sections.count) sections")
		keys.replace(with: sections, performDiff: animated)
	}
	
	/**
	Updates unbind button with current status.
	*/
	fileprivate func updateUnbindButton() {
		gdebug("Updating unbind bar button item")
		unbindBarButtonItem.isEnabled = !selectedKeyCodes.isEmpty
	}
}

// MARK: - Signals handling

extension JoystickBindingViewController {

	fileprivate func setupUnbindButtonTapSignal() {
		unbindBarButtonItem.reactive.tap.bind(to: self) { me, _ in
			ginfo("Unbinding")
			me.selectedKeyCodes.removeAll()
			me.selectionChangeHandler?(nil)
			me.updateUnbindButton()
			me.fetch(animated: true)
		}
	}
	
	fileprivate func setupTableSelectionSignal() {
		tableView.reactive.selectedRow.bind(to: self) { me, indexPath in
			let key = me.keys[indexPath]
			let sections = me.keys.sections
			
			let isAdding = sections.count <= 1 || !sections[0].contains(key)
			
			if isAdding {
				if me.selectedKeyCodes.count >= JoystickMappingObject.maximumKeysPerMapping {
					gwarn("Already have maximum number of keys mapped: (\(me.selectedKeyCodes.count))")
					me.tableView.deselectRow(at: indexPath, animated: true)
					return
				}

				ginfo("Adding \(key)")
				me.selectedKeyCodes.append(key)
				
			} else {
				ginfo("Removing \(key)")
				if let index = me.selectedKeyCodes.index(of: key) {
					me.selectedKeyCodes.remove(at: index)
				}
			}

			me.updateUnbindButton()
			me.fetch(animated: true)

			me.selectionChangeHandler?(me.selectedKeyCodes.isEmpty ? nil : me.selectedKeyCodes)
		}
	}
}
