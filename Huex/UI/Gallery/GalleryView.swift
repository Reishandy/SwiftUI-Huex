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
	@State private var gridScrollPosition = ScrollPosition()
	
	var body: some View {
		NavigationStack {
			FlushGridView(
				photoMetadatas,
				isReversed: true,
				scrollPosition: $gridScrollPosition
			) { photoMetadata in
				Color.clear
					.aspectRatio(1, contentMode: .fit)
					.overlay {
						PhotoView(photoMetadata: photoMetadata, contentMode: .fill)
					}
					.clipShape(RoundedRectangle(cornerRadius: 4))
					.contentShape(RoundedRectangle(cornerRadius: 4))
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
				
				ToolbarItem(placement: .topBarTrailing) {
					// TODO: Actions
					Image(systemName: "ellipsis")
				}
				
				ToolbarSpacer(placement: .topBarTrailing)
				
				ToolbarItem(placement: .topBarTrailing) {
					// TODO: Actions
					Text("Select")
						.padding()
				}
			}
			.navigationDestination(item: $selectedPhoto) { photo in
				PhotoDetailView(
					photoMetadatas: photoMetadatas.reversed(),
					initialPhotoID: photo.id,
					galleryNamespace: galleryNamespace,
					gridScrollPosition: $gridScrollPosition
				)
			}
		}
	}
}

#Preview {
	GalleryView()
		.modelContainer(PreviewData.container)
}
