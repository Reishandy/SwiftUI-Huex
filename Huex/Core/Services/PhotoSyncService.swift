//
//  PhotoSyncService.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import Foundation
import Photos
import SwiftData
import Observation

@Observable
@MainActor
final class PhotoSyncService: NSObject, PHPhotoLibraryChangeObserver {
	private let metadataWorker: PhotoMetadataWorker
	private let analysisWorker: PhotoAnalysisWorker
	
	private var fetchResult: PHFetchResult<PHAsset>?
	private var isObserving = false
	
	init(modelContainer: ModelContainer) {
		self.metadataWorker = PhotoMetadataWorker(modelContainer: modelContainer)
		self.analysisWorker = PhotoAnalysisWorker(modelContainer: modelContainer)
		super.init()
	}
	
	func start() async {
		let options = PHFetchOptions()
		options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		
		let result = PHAsset.fetchAssets(with: .image, options: options)
		fetchResult = result
		
		await performFullSync(with: result)
		
		guard !isObserving else { return }
		PHPhotoLibrary.shared().register(self)
		isObserving = true
	}
	
	nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
		Task { @MainActor in
			guard let current = self.fetchResult,
				  let details = changeInstance.changeDetails(for: current) else { return }
			
			self.fetchResult = details.fetchResultAfterChanges
			await self.applyIncrementalChange(details)
		}
	}
	
	private func performFullSync(with result: PHFetchResult<PHAsset>) async {
		var currentIDs: [String] = []
		result.enumerateObjects { asset, _, _ in
			currentIDs.append(asset.localIdentifier)
		}
		
		do {
			try await metadataWorker.insertMissing(assetIDs: currentIDs)
			try await metadataWorker.removeMissing(currentAssetIDs: currentIDs)
		} catch {
			print("> PhotoSyncService: full sync failed: \(error)")
		}
		
		await analysisWorker.run()
	}
	
	private func applyIncrementalChange(_ details: PHFetchResultChangeDetails<PHAsset>) async {
		do {
			let insertedIDs = details.insertedObjects.map(\.localIdentifier)
			if !insertedIDs.isEmpty {
				try await metadataWorker.insertMissing(assetIDs: insertedIDs)
			}
			
			let removedIDs = details.removedObjects.map(\.localIdentifier)
			if !removedIDs.isEmpty {
				try await metadataWorker.removeSpecific(assetIDs: removedIDs)
			}
			
			for changedAsset in details.changedObjects {
				try await metadataWorker.markStale(assetID: changedAsset.localIdentifier)
			}
		} catch {
			print("> PhotoSyncService: incremental sync failed: \(error)")
		}
		
		await analysisWorker.run()
	}
	
	func requestDeletion(of asset: PHAsset) async throws {
		try await PHPhotoLibrary.shared().performChanges {
			PHAssetChangeRequest.deleteAssets([asset] as NSArray)
		}
	}
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
}
