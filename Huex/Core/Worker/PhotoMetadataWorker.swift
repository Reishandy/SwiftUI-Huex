//
//  PhotoMetadataWorker.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import Foundation
import SwiftData

@ModelActor
actor PhotoMetadataWorker {
	func insertMissing(assets: [(id: String, date: Date)]) throws {
		guard !assets.isEmpty else { return }
		let existingIDs = Set(try modelContext.fetch(FetchDescriptor<PhotoMetadata>()).map(\.phaccessLocalIdentifier))
		
		for asset in assets where !existingIDs.contains(asset.id) {
			modelContext.insert(PhotoMetadata(phaccessLocalIdentifier: asset.id, timestamp: asset.date))
		}
		try modelContext.save()
	}
	
	func removeMissing(currentAssetIDs: [String]) throws {
		let currentIDs = Set(currentAssetIDs)
		let existing = try modelContext.fetch(FetchDescriptor<PhotoMetadata>())
		
		for metadata in existing where !currentIDs.contains(metadata.phaccessLocalIdentifier) {
			modelContext.delete(metadata)
		}
		
		try modelContext.save()
	}
	
	func removeSpecific(assetIDs: [String]) throws {
		guard !assetIDs.isEmpty else { return }
		
		let idsToRemove = Set(assetIDs)
		let existing = try modelContext.fetch(FetchDescriptor<PhotoMetadata>())
		
		for metadata in existing where idsToRemove.contains(metadata.phaccessLocalIdentifier) {
			modelContext.delete(metadata)
		}
		
		try modelContext.save()
	}
	
	func markStale(assetID: String) throws {
		let descriptor = FetchDescriptor<PhotoMetadata>(
			predicate: #Predicate<PhotoMetadata> { $0.phaccessLocalIdentifier == assetID }
		)
		guard let metadata = try modelContext.fetch(descriptor).first else { return }
		
		metadata.timestamp = .now // TODO: Reset the metadata
		try modelContext.save()
	}
}
