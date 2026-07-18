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
	@State private var isZoomed: Bool = false
	@State private var isToolbarVisible: Bool = true
	
	init(photoMetadatas: [PhotoMetadata], initialPhoto: PhotoMetadata, galleryNamespace: Namespace.ID) {
		self.photoMetadatas = photoMetadatas
		self.galleryNamespace = galleryNamespace
		_currentPhoto = State(initialValue: initialPhoto)
	}
	
	var body: some View {
		NavigationStack {
			TabView(selection: $currentPhoto) {
				ForEach(photoMetadatas) { photoMetadata in
					PhotoView(
						photoMetadata: photoMetadata,
						targetSize: PHImageManagerMaximumSize,
						contentMode: .fit
					)
					.zoomable(isZoomed: $isZoomed) {
						withAnimation {
							isToolbarVisible.toggle()
						}
					}
					.tag(photoMetadata)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.contentShape(Rectangle())
				}
			}
			.ignoresSafeArea()
			.tabViewStyle(.page(indexDisplayMode: .never))
			.scrollDisabled(isZoomed)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "chevron.backward")
					}
					.opacity(isToolbarVisible ? 1 : 0)
					.allowsHitTesting(isToolbarVisible)
				}
				.sharedBackgroundVisibility(isToolbarVisible ? .visible : .hidden)
				
				ToolbarItem(placement: .principal) {
					Text("TODO: INFO")
						.padding()
						.glassEffect()
						.opacity(isToolbarVisible ? 1 : 0)
						.allowsHitTesting(isToolbarVisible)
				}
				.sharedBackgroundVisibility(isToolbarVisible ? .visible : .hidden)
				
				ToolbarItem(placement: .primaryAction) {
					// TODO: Actions
					Image(systemName: "ellipsis")
						.opacity(isToolbarVisible ? 1 : 0)
						.allowsHitTesting(isToolbarVisible)
				}
				.sharedBackgroundVisibility(isToolbarVisible ? .visible : .hidden)
				
				ToolbarItem(placement: .bottomBar) {
					// TODO: Share
					Image(systemName: "square.and.arrow.up")
						.opacity(isToolbarVisible ? 1 : 0)
						.allowsHitTesting(isToolbarVisible)
				}
				.sharedBackgroundVisibility(isToolbarVisible ? .visible : .hidden)
				
				ToolbarSpacer(placement: .bottomBar)
				
				ToolbarItem(placement: .bottomBar) {
					// TODO: Palette
					Text("TODO: PALETTE")
						.opacity(isToolbarVisible ? 1 : 0)
						.allowsHitTesting(isToolbarVisible)
				}
				.sharedBackgroundVisibility(isToolbarVisible ? .visible : .hidden)
				
				ToolbarSpacer(placement: .bottomBar)
				
				ToolbarItem(placement: .bottomBar) {
					// TODO: Delete
					Image(systemName: "trash")
						.opacity(isToolbarVisible ? 1 : 0)
						.allowsHitTesting(isToolbarVisible)
				}
				.sharedBackgroundVisibility(isToolbarVisible ? .visible : .hidden)
			}
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
