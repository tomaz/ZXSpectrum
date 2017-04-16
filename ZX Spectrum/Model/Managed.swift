//
//  Created by Tomaz Kragelj on 19.12.16.
//  Copyright © 2016 Tomaz Kragelj. All rights reserved.
//

import Foundation
import CoreData

/**
Defines the requirements for managed objects.
*/
protocol Managed: class, NSFetchRequestResult {
	
	/// Name of this entity.
	static var entityName: String { get }
	
	/// Sort descriptors for default fetch.
	static var defaultSortDescriptors: [NSSortDescriptor] { get }
	
	/// The important properties we should consider pre-fetching.
	static var importantPropertiesToFetch: [String]? { get }
	
//	/// Returns default sorted fetch request for this managed object.
//	static func sortedFetchRequest() -> NSFetchRequest<Self>
}

extension Managed {
	
	/// No sort descriptors by default.
	static var defaultSortDescriptors: [NSSortDescriptor] {
		return []
	}
	
	/// No important property to fetch by default.
	static var importantPropertiesToFetch: [String]? {
		return nil
	}
}

extension Managed where Self: NSManagedObject {
	
	/**
	We can derive entity name for `NSManagedObject` subclass.
	*/
	static var entityName: String {
		return entity().name!
	}

//	/**
//	Helper function for using `defaultSortDescriptors` for fetching.
//	*/
//	static func sortedFetchRequest() -> NSFetchRequest<Self> {
//		let result = NSFetchRequest<Self>(entityName: entityName)
//		result.sortDescriptors = defaultSortDescriptors
//		return result
//	}

	/**
	Finds the object matching given predicate, or creates one if not found, in the given context.
	*/
	static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: ((Self) -> ())? = nil) -> Self {
		guard let object = findOrFetch(in: context, matching: predicate) else {
			let newObject: Self = Self(context: context)
			configure?(newObject)
			return newObject
		}
		return object
	}
	
	/**
	Finds or fetches the object matching given predicate in given context.
	*/
	static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
		guard let object = materializedObject(in: context, matching: predicate) else {
			return fetch(in: context) { request in
				request.predicate = predicate
				request.returnsObjectsAsFaults = false
				request.fetchLimit = 1
			}.first
		}
		return object
	}
	
	/**
	Returns existing object matching the given predicate in the given context.
	*/
	static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
		for object in context.registeredObjects where !object.isFault {
			guard let result = object as? Self, predicate.evaluate(with: result) else {
				continue
			}
			return result
		}
		return nil
	}
	
	/**
	Fetches the objects in the given context.
	*/
	static func fetch(in context: NSManagedObjectContext, configure: ((NSFetchRequest<Self>) -> ())? = nil) -> [Self] {
		let request = NSFetchRequest<Self>(entityName: Self.entityName)
		configure?(request)
		return try! context.fetch(request)
	}
	
	/**
	Returns number of objects in the given context.
	*/
	static func count(in context: NSManagedObjectContext, configure: ((NSFetchRequest<Self>) -> ())? = nil) -> Int {
		let request = NSFetchRequest<Self>(entityName: entityName)
		configure?(request)
		return try! context.count(for: request)
	}
	
	/**
	Deletes the object.
	*/
	func delete() {
		managedObjectContext?.delete(self)
	}
}
