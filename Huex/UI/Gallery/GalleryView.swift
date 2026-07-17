//
//  GalleryView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI

struct GalleryView: View {
	@Namespace private var galleryNamespace
	
	@State private var selectedPhoto: FlushPreview?
	
	var body: some View {
		NavigationStack {
			// TODO: Update
			FlushGridView((1...99).map{ FlushPreview(id: $0) }, isReversed: true) { item in
				RoundedRectangle(cornerRadius: 4)
					.aspectRatio(1, contentMode: .fit)
					.foregroundStyle(.secondary)
					.onTapGesture {
						selectedPhoto = item
					}
					.matchedTransitionSource(id: item.id, in: galleryNamespace)
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
				PhotoDetailView()
					.navigationTransition(.zoom(sourceID: photo.id, in: galleryNamespace))
			}
		}
	}
}

#Preview {
	GalleryView()
}
