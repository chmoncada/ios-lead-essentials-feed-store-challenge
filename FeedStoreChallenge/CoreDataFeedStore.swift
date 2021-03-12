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

	public init(url: URL, bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStore",
												   url: url,
												   in: bundle)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		context.perform {
			do {
				if let cache = try CoreDataCache.cache(in: context) {
					completion(.found(
								feed: cache.localFeed,
								timestamp: cache.timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let context = self.context
		context.perform {
			do {
				try CoreDataCache.cache(in: context).map(context.delete).map(context.save)
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		context.perform {
			do {
				let cache = try CoreDataCache.newCache(in: context)
				cache.timestamp = timestamp
				cache.feed = CoreDataFeedImage.feedImages(from: feed, in: context)
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}

	}
}

private extension NSPersistentContainer {
	enum LoadingError: Error {
		case modelNotFound
		case failedToLoad
	}

	static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = bundle.url(forResource: name, withExtension: "momd")
				.flatMap({ NSManagedObjectModel(contentsOf: $0) }) else {
			throw LoadingError.modelNotFound
		}

		let description = NSPersistentStoreDescription(url: url)
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		var failToLoadError: Error?
		container.loadPersistentStores { failToLoadError = $1 }

		if failToLoadError != nil { throw LoadingError.failedToLoad }

		return container
	}
}

@objc(CoreDataCache)
private class CoreDataCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet

	// Helpers

	var localFeed: [LocalFeedImage] {
		feed.compactMap { ($0 as? CoreDataFeedImage)?.local }
	}

	static func cache(in context: NSManagedObjectContext) throws -> CoreDataCache? {
		let request = NSFetchRequest<CoreDataCache>(entityName: CoreDataCache.entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}

	static func newCache(in context: NSManagedObjectContext) throws -> CoreDataCache {
		try cache(in: context).map { context.delete($0) }
		return CoreDataCache(context: context)
	}
 }

@objc(CoreDataFeedImage)
private class CoreDataFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: CoreDataCache

	var local: LocalFeedImage {
		.init(id: id, description: imageDescription, location: location, url: url)
	}

	static func feedImages(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		NSOrderedSet(array: localFeed.map{ local in
			let coreDataFeedImage = CoreDataFeedImage(context: context)
			coreDataFeedImage.id = local.id
			coreDataFeedImage.imageDescription = local.description
			coreDataFeedImage.location = local.location
			coreDataFeedImage.url = local.url
			return coreDataFeedImage
		})
	}
 }
