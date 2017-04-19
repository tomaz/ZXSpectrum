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
	Bond for managing files collection view.
	*/
	final class Bond: NSObject, TableViewBond {
		
		typealias DataSource = Observable2DArray<String, FileObject>
		
		private lazy var indexes = Property([String]())
		
		// MARK: - Callbacks
		
		/// Called when user selects to insert the object for playback.
		var didRequestInsert: ((FileObject) -> Void)? = nil
		
		/// Called when user wants to delete the object
		var didRequestDelete: ((FileObject) -> Void)? = nil

		// MARK: - Initialization
		
		/**
		Initializes the bond to work for the given table view.
		*/
		func initialize(tableView: UITableView) {
			tableView.reactive.dataSource.feed(
				property: indexes,
				to: #selector(sectionIndexTitles(for:)),
				map: { (value: [String], _: UITableView) -> [String] in return value }
			)
		}
		
		// MARK: - Fetching
		
		/**
		Fetches files from database and returns array.
		*/
		func fetch(in context: NSManagedObjectContext) -> DataSource {
			typealias SectionType = Observable2DArraySection<String, FileObject>
			var sections = [String: [FileObject]]()
			
			// Fetch and prepare dictionary of letters/objects.
			let objects = FileObject.fetch(in: context)
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
			
			// Assign and return.
			indexes.value = sorted.flatMap { $0.key }
			return result
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
	}
}
