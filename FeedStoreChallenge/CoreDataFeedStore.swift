//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Charles Moncada on 11/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	public init(bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStore", in: bundle)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

	}
}

private extension NSPersistentContainer {
	enum LoadingError: Error {
		case modelNotFound
		case failedToLoad
	}

	static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = bundle.url(forResource: name, withExtension: "momd")
				.flatMap({ NSManagedObjectModel(contentsOf: $0) }) else {
			throw LoadingError.modelNotFound
		}

		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		var failToLoadError: Error?
		container.loadPersistentStores { failToLoadError = $1 }

		if failToLoadError != nil { throw LoadingError.failedToLoad }

		return container
	}
}

private class CoreDataCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
 }

 private class CoreDataFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: CoreDataCache
 }
