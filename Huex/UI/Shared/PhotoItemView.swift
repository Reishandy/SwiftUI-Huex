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
	var targetSize: CGSize = PHImageManagerMaximumSize
	var contentMode: ContentMode = .fill
	
	@State private var image: UIImage?
	
	var body: some View {
		Group {
			if let image {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: contentMode)
			} else {
				Rectangle()
					.fill(Color.secondary.opacity(0.1))
					.aspectRatio(3/4, contentMode: contentMode)
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
    PhotoItemView(phAsset: PHAsset())
}
