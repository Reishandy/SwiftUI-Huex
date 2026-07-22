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
					photoMetadata.bucketRawValue == nil
				},
				sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
			)
			descriptor.fetchLimit = 1
			
			let metadatas = try modelContext.fetch(descriptor)
			guard let metadata = metadatas.first else { break }
			
			if let result = await analyzePhoto(for: metadata.phaccessLocalIdentifier) {
				metadata.swatches = result.swatches
				metadata.bucket = result.bucket
			} else {
				metadata.swatches = []
				metadata.bucket = .mixed
			}
			
			try modelContext.save()
		}
	}
	
	private func analyzePhoto(for localIdentifier: String) async -> (bucket: ColorBucket, swatches: [Swatch])? {
		let assets = fetchPHassets(localIdentifiers: [localIdentifier])
		guard let asset = assets.first else { return nil }
	
		let targetSize = CGSize(width: 400, height: 400)
		guard let image = await fetchImage(asset: asset, targetSize: targetSize) else { return nil }
		
		return analyzeImage(image)
	}
}
