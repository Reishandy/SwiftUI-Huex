//
//  PhotoDetailView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import Photos
import SwiftData

struct PhotoDetailView: View {
	@Environment(\.dismiss) private var dismiss
	
	let photoMetadatas: [PhotoMetadata]
	let galleryNamespace: Namespace.ID
	
	@State private var currentPhoto: PhotoMetadata
	@State private var isZoomed = false
	@State private var isToolbarVisible = true
	@State private var scrollPosition: PhotoMetadata.ID?
	
	init(photoMetadatas: [PhotoMetadata], initialPhoto: PhotoMetadata, galleryNamespace: Namespace.ID) {
		self.photoMetadatas = photoMetadatas
		self.galleryNamespace = galleryNamespace
		_currentPhoto = State(initialValue: initialPhoto)
		_scrollPosition = State(initialValue: initialPhoto.id)
	}
	
	var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				let size = geometry.size
				
				ScrollView(.horizontal) {
					LazyHStack(spacing: 0) {
						ForEach(photoMetadatas) { photoMetadata in
							PhotoView(
								photoMetadata: photoMetadata,
								targetSize: PHImageManagerMaximumSize,
								contentMode: .fit
							)
							.zoomable(isZoomed: $isZoomed) {
								withAnimation { isToolbarVisible.toggle() }
							}
							.frame(width: size.width, height: size.height)
							.contentShape(Rectangle())
							.id(photoMetadata.id)
						}
					}
					.scrollTargetLayout()
				}
				.scrollTargetBehavior(.paging)
				.scrollPosition(id: $scrollPosition)
				.scrollDisabled(isZoomed)
				.onChange(of: scrollPosition) { _, newId in
					guard let newId, newId != currentPhoto.id,
						  let match = photoMetadatas.first(where: { $0.id == newId }) else { return }
					currentPhoto = match
				}
				.onChange(of: currentPhoto) { _, newPhoto in
					guard scrollPosition != newPhoto.id else { return }
					withAnimation { scrollPosition = newPhoto.id }
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.ignoresSafeArea()
			.overlay(alignment: .bottom) {
				// TODO: Fix fast scroll stutter
				PhotoFilmstripView(photoMetadatas: photoMetadatas, currentPhoto: $currentPhoto)
					.padding(.bottom, 10)
					.opacity(isToolbarVisible ? 1 : 0)
					.allowsHitTesting(isToolbarVisible)
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "chevron.backward")
					}
				}
				
				ToolbarItem(placement: .principal) {
					Text("TODO: INFO")
						.padding()
						.glassEffect()
				}
				
				ToolbarItem(placement: .primaryAction) {
					// TODO: Actions
					Image(systemName: "ellipsis")
				}
				
				ToolbarItem(placement: .bottomBar) {
					// TODO: Share
					Image(systemName: "square.and.arrow.up")
				}
				
				ToolbarSpacer(placement: .bottomBar)
				
				ToolbarItem(placement: .bottomBar) {
					// TODO: Palette
					Text("TODO: PALETTE")
				}
				
				ToolbarSpacer(placement: .bottomBar)
				
				ToolbarItem(placement: .bottomBar) {
					// TODO: Delete
					Image(systemName: "trash")
				}
			}
			.toolbar(isToolbarVisible ? .visible : .hidden, for: .navigationBar, .bottomBar)
		}
		.navigationTransition(.zoom(sourceID: currentPhoto.phaccessLocalIdentifier, in: galleryNamespace))
		.interactiveDismissDisabled(isZoomed)
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
