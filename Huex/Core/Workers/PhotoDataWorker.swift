//
//  MetadataSyncWorker.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import Foundation
import SwiftUI
import SwiftData
import Photos

@ModelActor
actor PhotoDataWorker {
	func syncMetadata(phAssets: [PHAsset]) async throws {
		let descriptor = FetchDescriptor<PhotoMetadata>()
		let photoMetadatas = try modelContext.fetch(descriptor)
		
		var photoMetadatasSet = Set(photoMetadatas.map { $0.phaccessLocalIdentifier })
		
		for phAsset in phAssets {
			if photoMetadatasSet.contains(phAsset.localIdentifier) {
				photoMetadatasSet.remove(phAsset.localIdentifier)
			} else {
				modelContext.insert(
					PhotoMetadata(phaccessLocalIdentifier: phAsset.localIdentifier, timestamp: phAsset.creationDate ?? .now)
				)
			}
		}
		
		for photoMetadata in photoMetadatas where photoMetadatasSet.contains(photoMetadata.phaccessLocalIdentifier) {
			modelContext.delete(photoMetadata)
		}
		
		try modelContext.save()
	}
	
	func analyzePhotos() async throws {
		while true {
			var descriptor = FetchDescriptor<PhotoMetadata>(
				predicate: #Predicate<PhotoMetadata> { photoMetadata in
					photoMetadata.bucketRawValue == nil ||
					photoMetadata.swatches == nil
				},
				sortBy: [SortDescriptor(\.timestamp)]
			)
			descriptor.fetchLimit = 1
			
			let metadatas = try modelContext.fetch(descriptor)
			guard let metadata = metadatas.first else { break }
			
			// TODO: Set the result here
			print("would analyze: ", metadata.phaccessLocalIdentifier)
			
			guard let result = await analyzePhoto(for: metadata.phaccessLocalIdentifier) else { break /* TODO: Continue */ }
			
			try modelContext.save()
		}
	}
	
	private func analyzePhoto(for localIdentifier: String) async -> (bucket: ColorBucket, swatches: [Swatch])? {
		let assets = fetchPHassets(localIdentifiers: [localIdentifier])
		guard let asset = assets.first else { return nil }
		
		// TODO: Deicde size
		let targetSize = CGSize(width: 100, height: 100)
		guard let image = await fetchImage(asset: asset, targetSize: targetSize) else { return nil }
		
		// TODO: Analyze here
		return nil
	}
}
