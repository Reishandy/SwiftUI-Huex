//
//  PhotoUtilitiess.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import Foundation
import SwiftUI
import Photos

nonisolated func fetchPHassets(localIdentifiers: [String]? = nil) -> [PHAsset] {
	let fetchOptions = PHFetchOptions()
	fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
	
	var fetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
	if let localIdentifiers {
		fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)
	} else {
		fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
	}
	
	var phassets: [PHAsset] = []
	fetchResult.enumerateObjects { asset, _, _ in
		phassets.append(asset)
	}
	return phassets
}

// TODO: Cache?
nonisolated func fetchImage(
	asset: PHAsset,
	targetSize: CGSize
) async -> UIImage? {
	let manager = PHImageManager.default()
	let options = PHImageRequestOptions()
	options.isNetworkAccessAllowed = true
	options.deliveryMode = .highQualityFormat
	
	return await withCheckedContinuation { continuation in
		var didResume = false
		
		manager.requestImage(
			for: asset,
			targetSize: targetSize,
			contentMode: .aspectFill,
			options: options
		) { result, info in
			if !didResume {
				didResume = true
				continuation.resume(returning: result)
			}
		}
	}
}

nonisolated func deletePhotos(localIdentifiers: [String]) async -> Bool {
	let assets = fetchPHassets(localIdentifiers: localIdentifiers)
	
	do {
		try await PHPhotoLibrary.shared().performChanges {
			PHAssetChangeRequest.deleteAssets(assets as NSArray)
		}
		
		return true
	} catch {
		print("Error or user cancelled: \(error)")
		return false
	}
}
