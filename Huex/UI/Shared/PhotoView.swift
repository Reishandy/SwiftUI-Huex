//
//  PhotoView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import SwiftUI

struct PhotoView: View {
	let metadata: PhotoMetadata
	var targetSize: CGSize = CGSize(width: 300, height: 300)
	
	@State private var image: UIImage?
	
	var body: some View {
		Group {
			if let image {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fill)
			} else {
				Rectangle()
					.fill(.secondary)
					.overlay {
						Image(systemName: "photo.trianglebadge.exclamationmark")
							.foregroundStyle(.secondary)
					}
			}
		}
		.task(id: metadata.phaccessLocalIdentifier) {
			guard let asset = fetchPHAsset(localIdentifier: metadata.phaccessLocalIdentifier) else { return }
			image = await requestImage(for: asset, targetSize: targetSize)
		}
	}
}

#Preview {
	PhotoView(metadata: PhotoMetadata(phaccessLocalIdentifier: "preview-1"))
}
