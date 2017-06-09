//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData
import ReactiveKit
import Bond

extension FilesViewController {
	
	/**
	Bond for managing files table view.
	*/
	final class Bond: NSObject, TableViewBond, UITableViewDelegate {
		
		typealias DataSource = Observable2DArray<String, FileObject>
		typealias SectionType = Observable2DArraySection<String, FileObject>
		
		private var tableView: UITableView!
		
		private let indexPathForWillSelect = Property<NSIndexPath?>(nil)
		
		// MARK: - Callbacks
		
		/// Called when user selects to insert the object for playback.
		var didRequestInsert: ((FileObject, SpectrumFileInfo?) -> Void)? = nil
		
		/// Called when user wants to delete the object
		var didRequestDelete: ((FileObject) -> Void)? = nil

		// MARK: - Initialization
		
		/**
		Initializes the bond to work for the given table view.
		*/
		func initialize(tableView: UITableView) {
			self.tableView = tableView
			
			tableView.reactive.delegate.forwardTo = self
		}
		
		// MARK: - Fetching
		
		/**
		Fetches files from database and returns array.
		*/
		func fetch(in context: NSManagedObjectContext) -> DataSource {
			switch UserDefaults.standard.filesSortOption {
			case .name: return sectionsSortedByName(in: context)
			case .usage: return sectionsSortedByUsage(in: context)
			}
		}
		
		private func sectionsSortedByName(in context: NSManagedObjectContext) -> DataSource {
			// Fetch the objects.
			let objects = FileObject.fetch(in: context)

			// Prepare dictionary of letters/objects.
			var sections = [String: [FileObject]]()
			for object in objects {
				let letter = object.letter
				
				if sections[letter] == nil {
					sections[letter] = []
				}
				
				sections[letter]!.append(object)
			}
			
			// Sort dictionary by keys.
			let sorted = sections.sorted(by: { $0.key < $1.key })
			
			// Prepare 2D array.
			let result = MutableObservable2DArray<String, FileObject>()
			for (letter, items) in sorted {
				result.appendSection(SectionType(metadata: letter, items: items))
			}
			
			return result
		}
		
		private func sectionsSortedByUsage(in context: NSManagedObjectContext) -> DataSource {
			// Fetch the objects.
			let objects = FileObject.fetch(in: context) { $0.sortDescriptors = FileObject.usageSortDescriptors }
			
			let result = MutableObservable2DArray<String, FileObject>()

			// Group objects into range array based on their usage date.
			let ranges = Date.standardRanges
			var rangeIndex = ranges.startIndex
			var range = ranges[rangeIndex]
			var items = [FileObject]()
			var unusedObjects = [FileObject]()

			// Prepare array of used objects. Create new sections as soon as we reach next range.
			for object in objects {
				guard let lastUsed = object.used else {
					unusedObjects.append(object)
					continue
				}
				
				while lastUsed < range.startDate {
					if items.count > 0 {
						result.appendSection(SectionType(metadata: range.name, items: items))
						items = []
					}
					
					rangeIndex += 1
					range = ranges[rangeIndex]
				}
				
				items.append(object)
			}
			
			if items.count > 0 {
				result.appendSection(SectionType(metadata: range.name, items: items))
			}
			
			if unusedObjects.count > 0 {
				result.appendSection(SectionType(metadata: NSLocalizedString("Never"), items: unusedObjects))
			}

			return result
		}
		
		// MARK: - Helper functions
		
		/**
		Selects or deselects the cell at the given index path.
		*/
		func selectCell(at indexPath: IndexPath, select: Bool = true) {
			if let cell = tableView.cellForRow(at: indexPath) as? FileTableViewCell {
				cell.select(selected: select)
			}
		}
		
		// MARK: - TableViewBond
		
		func titleForHeader(in section: Int, dataSource: DataSource) -> String? {
			let section = dataSource[section]
			return section.metadata
		}
		
		func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: DataSource) -> UITableViewCell {
			let object = dataSource[indexPath]
			
			gdebug("Dequeuing cell at \(indexPath) for \(object)")
			let result = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileTableViewCell
			
			result.configure(object: object)
			
			result.didRequestInsert = didRequestInsert
			result.didRequestDelete = didRequestDelete
			
			return result
		}
		
		// MARK: - UITableViewDelegate
		
		func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
			// If cell is already selected, deselect it. Note we must manually call deselection delegate function in order to have it pick up by `deselectedRow` signal.
			if let cell = tableView.cellForRow(at: indexPath), cell.isSelected {
				tableView.deselectRow(at: indexPath, animated: true)
				tableView.delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
				return nil
			}
			
			// Otherwise allow selection.
			return indexPath
		}
	}
}
