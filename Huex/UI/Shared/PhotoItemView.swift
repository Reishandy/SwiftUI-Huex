//
//  PhotoItemView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import SwiftUI
import Photos

struct PhotoItemView: View {
	let phAsset: PHAsset?
	let photoMetadata: PhotoMetadata
	var targetSize: CGSize = PHImageManagerMaximumSize
	var contentMode: ContentMode = .fill
	
	@State private var image: UIImage?
	
	var body: some View {
		ZStack {
			Color.clear
			
			if let image {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: contentMode)
			} else {
				Rectangle()
					.fill(.clear)
					.overlay {
						Image(systemName: "photo.trianglebadge.exclamationmark")
							.foregroundStyle(.secondary)
					}
			}
		}
		.task(id: phAsset) {
			if let phAsset {
				image = await fetchImage(asset: phAsset, targetSize: targetSize)
			}
		}
	}
}

#Preview {
    PhotoItemView(phAsset: PHAsset(), photoMetadata: PhotoMetadata(phaccessLocalIdentifier: "preview"))
}
