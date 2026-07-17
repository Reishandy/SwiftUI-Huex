//
//  PhotoDetailView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import Photos

struct PhotoDetailView: View {
	@Environment(\.dismiss) private var dismiss
	
	let photoMetadatas: [PhotoMetadata]
	let galleryNamespace: Namespace.ID
	
	@State private var currentPhoto: PhotoMetadata
	
	init(photoMetadatas: [PhotoMetadata], initialPhoto: PhotoMetadata, galleryNamespace: Namespace.ID) {
		self.photoMetadatas = photoMetadatas
		self.galleryNamespace = galleryNamespace
		_currentPhoto = State(initialValue: initialPhoto)
	}
	
	// TODO: Fix split second PhotoViiew gray showing
	// TODO: Fix the swipe to unloaded photos cause it to stop midway
	// TODO: Preview like the photos
	// TODO: Toolbar and hide on click
	var body: some View {
		NavigationStack {
			TabView(selection: $currentPhoto) {
				ForEach(photoMetadatas) { photoMetadata in
					// TODO: Drag, zoom, and such
					PhotoView(
						photoMetadata: photoMetadata,
						targetSize: PHImageManagerMaximumSize,
						contentMode: .fit
					)
					.tag(photoMetadata)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.contentShape(Rectangle())
					.ignoresSafeArea()
				}
			}
			.ignoresSafeArea()
			.tabViewStyle(.page(indexDisplayMode: .never))
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "chevron.backward")
					}
				}
			}
		}
		.navigationTransition(.zoom(sourceID: currentPhoto.id, in: galleryNamespace))
	}
}

#Preview {
	@Previewable @Namespace var namespace
	
	PhotoDetailView(
		photoMetadatas: [PhotoMetadata(phaccessLocalIdentifier: "preview-1")],
		initialPhoto: PhotoMetadata(phaccessLocalIdentifier: "preview-1"),
		galleryNamespace: namespace
	)
}
