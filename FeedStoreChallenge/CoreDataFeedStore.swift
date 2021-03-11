//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Charles Moncada on 11/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {

	public init() {}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

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
