//
//  PhotoView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import SwiftUI

struct PhotoView: View {
	let photoMetadata: PhotoMetadata
	var targetSize: CGSize = CGSize(width: 300, height: 300)
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
		.animation(.default, value: image)
		.task(id: photoMetadata.phaccessLocalIdentifier) {
			guard let asset = fetchPHAsset(localIdentifier: photoMetadata.phaccessLocalIdentifier) else { return }
			image = await fetchImage(for: asset, targetSize: targetSize)
		}
	}
}

#Preview {
	PhotoView(photoMetadata: PhotoMetadata(phaccessLocalIdentifier: "preview-1"))
}
