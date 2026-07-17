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

func requestImage(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
	await withCheckedContinuation { continuation in
		let options = PHImageRequestOptions()
		options.deliveryMode = .highQualityFormat
		options.isNetworkAccessAllowed = true
		
		imageManager.requestImage(
			for: asset,
			targetSize: targetSize,
			contentMode: .aspectFill,
			options: options
		) { image, _ in
			continuation.resume(returning: image)
		}
	}
}
