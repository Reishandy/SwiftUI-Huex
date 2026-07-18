//
//  GalleryView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
	@Namespace private var galleryNamespace
	
	@Query(sort: \PhotoMetadata.timestamp, order: .forward)
	private var photoMetadatas: [PhotoMetadata]
	
	@State private var initialPhoto: PhotoMetadata?
	
	var body: some View {
		NavigationStack {
			FlushGridView(photoMetadatas, isReversed: true) { photoMetadata in
				Color.clear
					.aspectRatio(1, contentMode: .fit)
					.overlay {
						PhotoView(photoMetadata: photoMetadata, contentMode: .fill)
					}
					.clipShape(RoundedRectangle(cornerRadius: 4))
					.contentShape(RoundedRectangle(cornerRadius: 4))
					.onTapGesture {
						initialPhoto = photoMetadata
					}
					.matchedTransitionSource(id: photoMetadata.phaccessLocalIdentifier, in: galleryNamespace)
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					TitleView(
						titleName: "Gallery",
						totalImages: 100,
						processedImages: 10,
						isProcessing: false
						// TODO: More detail
					)
				}
				.sharedBackgroundVisibility(.hidden)
			}
			.fullScreenCover(item: $initialPhoto) { photo in
				PhotoDetailView(
					photoMetadatas: photoMetadatas.reversed(),
					initialPhoto: photo,
					galleryNamespace: galleryNamespace
				)
			}
		}
	}
}

#Preview {
	GalleryView()
		.modelContainer(PreviewData.container)
}
