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
	let photoMetadatas: [PhotoMetadata]
	let galleryNamespace: Namespace.ID
	let initialPhotoID: PhotoMetadata.ID
	
	@State private var activeID: PhotoMetadata.ID?
	@State private var isZoomed = false
	@State private var isToolbarVisible = true
	@Binding var gridScrollPosition: ScrollPosition
	
	init(
		photoMetadatas: [PhotoMetadata],
		initialPhotoID: PhotoMetadata.ID,
		galleryNamespace: Namespace.ID,
		gridScrollPosition: Binding<ScrollPosition>
	) {
		self.photoMetadatas = photoMetadatas
		self.initialPhotoID = initialPhotoID
		self.galleryNamespace = galleryNamespace
		self._gridScrollPosition = gridScrollPosition
		_activeID = State(initialValue: initialPhotoID)
	}
	
	var body: some View {
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
							if !isZoomed {
								withAnimation {
									isToolbarVisible.toggle()
								}
							}
						}
						.frame(width: size.width, height: size.height)
						.contentShape(Rectangle())
						.id(photoMetadata.id)
					}
				}
				.scrollTargetLayout()
			}
			.scrollIndicators(.hidden)
			.scrollTargetBehavior(.paging)
			.scrollPosition(id: $activeID)
			.scrollDisabled(isZoomed)
			.onChange(of: isZoomed) { _, isNowZoomed in
				withAnimation(.easeInOut) {
					isToolbarVisible = !isNowZoomed
				}
			}
			.onChange(of: activeID) { _, newID in
				if let newID {
					gridScrollPosition = ScrollPosition(id: newID, anchor: .center)
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.ignoresSafeArea()
		.overlay(alignment: .bottom) {
			PhotoFilmstripView(photoMetadatas: photoMetadatas, activeID: $activeID)
				.padding(.bottom, 10)
				.opacity(isToolbarVisible ? 1 : 0)
				.allowsHitTesting(isToolbarVisible)
		}
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("TODO: INFO")
					.padding()
			}
			ToolbarItem(placement: .primaryAction) {
				Image(systemName: "ellipsis")
			}
			ToolbarItem(placement: .bottomBar) {
				Image(systemName: "square.and.arrow.up")
			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Text("TODO: PALETTE")
			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Image(systemName: "trash")
			}
		}
		.toolbar(isToolbarVisible ? .visible : .hidden, for: .navigationBar, .bottomBar)
		.navigationTransition(.zoom(sourceID: activeID ?? initialPhotoID, in: galleryNamespace))
		.interactiveDismissDisabled(isZoomed)
	}
}

#Preview {
	@Previewable @Namespace var namespace
	
	PhotoDetailView(
		photoMetadatas: [PhotoMetadata(phaccessLocalIdentifier: "preview-1")],
		initialPhotoID: PhotoMetadata(phaccessLocalIdentifier: "preview-1").id,
		galleryNamespace: namespace,
		gridScrollPosition: .constant(ScrollPosition())
	)
}
