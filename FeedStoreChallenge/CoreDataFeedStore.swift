//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Charles Moncada on 11/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

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
