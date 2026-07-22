//
//  PhotoStoreManager.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import Foundation
import SwiftData
import Photos

@MainActor
@Observable
class PhotoStoreManager: NSObject, PHPhotoLibraryChangeObserver {
	private let photoDataWorker: PhotoDataWorker
	
	var phAssets: [String: PHAsset] = [:]
	var isAnalyzing: Bool =  false
	
	private var needsAnotherAnalyzingPass: Bool = false
	
	init(modelContainer: ModelContainer? = nil) {
		if let modelContainer {
			self.photoDataWorker = PhotoDataWorker(modelContainer: modelContainer)
		} else {
			// For preview, I know it is not good...
			self.photoDataWorker = PhotoDataWorker(modelContainer: try! ModelContainer(for: PhotoMetadata.self))
			var mockDict: [String: PHAsset] = [:]
			for i in 1...999 {
				mockDict["preview_id_\(i)"] = PHAsset()
			}
			self.phAssets = mockDict
		}
		
		super.init()
	}
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	func start() async {
		PHPhotoLibrary.shared().register(self)
		await self.fetchSycnAndAnalyzePhotos()
	}
	
	func analyzePhotos() async throws {
		if self.isAnalyzing {
			self.needsAnotherAnalyzingPass = true
			return
		}
		
		self.isAnalyzing = true
		
		repeat {
			self.needsAnotherAnalyzingPass = false
			
			try await self.photoDataWorker.analyzePhotos()
		} while self.needsAnotherAnalyzingPass
		
		self.isAnalyzing = false
	}
	
	nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
		Task { @MainActor in
			await self.fetchSycnAndAnalyzePhotos()
		}
	}
	
	private func fetchSycnAndAnalyzePhotos() async {
		let fetchedAssets = await self.fetchPhotos()
		self.phAssets = Dictionary(uniqueKeysWithValues: fetchedAssets.map { ($0.localIdentifier, $0) })
		
		do {
			try await self.photoDataWorker.syncMetadata(phAssets: fetchedAssets)
			
			try await self.analyzePhotos()
		} catch {
			print("> Something went wrong while triggering worker: \(error)")
		}
	}
	
	private func fetchPhotos() async -> [PHAsset] {
		let taskResult: [PHAsset] = await Task.detached(priority: .userInitiated) {
			return fetchPHassets()
		}.value
		
		return taskResult
	}
}
