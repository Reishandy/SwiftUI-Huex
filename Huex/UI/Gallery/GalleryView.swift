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
	
	@State private var selectedPhoto: PhotoMetadata?
	
	var body: some View {
		NavigationStack {
			FlushGridView(photoMetadatas, isReversed: true) { photoMetadata in
				Color.clear
					.aspectRatio(1, contentMode: .fit)
					.overlay {
						PhotoView(photoMetadata: photoMetadata, contentMode: .fill)
					}
					.clipShape(RoundedRectangle(cornerRadius: 4))
					.onTapGesture {
						selectedPhoto = photoMetadata
					}
					.matchedTransitionSource(id: photoMetadata.id, in: galleryNamespace)
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
			.fullScreenCover(item: $selectedPhoto) { photo in
				PhotoDetailView(photoMetadata: photo)
					.navigationTransition(.zoom(sourceID: photo.id, in: galleryNamespace))
			}
		}
	}
}

#Preview {
	GalleryView()
		.modelContainer(PreviewData.container)
}
