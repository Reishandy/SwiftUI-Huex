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
			descriptor.fetchLimit = 50
			
			let metadatas = try modelContext.fetch(descriptor)
			guard !metadatas.isEmpty else { break }
			
			for (index, metadata) in metadatas.enumerated() {
				if let result = await analyzePhoto(for: metadata.phaccessLocalIdentifier) {
					metadata.swatches = result.swatches
					metadata.bucket = result.bucket
				} else {
					metadata.swatches = []
					metadata.bucket = .mixed
				}
				
				if index > 0 && index % 10 == 0 {
					try modelContext.save()
				}
				
				try await Task.sleep(for: .milliseconds(300))
			}
			
			try modelContext.save()
		}
	}
	
	private func analyzePhoto(for localIdentifier: String) async -> (bucket: ColorBucket, swatches: [Swatch])? {
		let assets = fetchPHassets(localIdentifiers: [localIdentifier])
		guard let asset = assets.first else { return nil }
	
		let targetSize = CGSize(width: 120, height: 120)
		guard let image = await fetchImage(asset: asset, targetSize: targetSize) else { return nil }
		
		return analyzeImage(image)
	}
}
