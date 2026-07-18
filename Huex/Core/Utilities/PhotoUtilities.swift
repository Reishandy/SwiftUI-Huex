//
//  PhotoUtilities.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import Photos
import UIKit

private let imageManager = PHCachingImageManager()

func fetchPHAsset(localIdentifier: String) -> PHAsset? {
	PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
}

nonisolated func fetchImage(
	for asset: PHAsset,
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
