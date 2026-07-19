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
	@Environment(NavigationState.self) private var navState

	@Query(sort: \PhotoMetadata.timestamp, order: .forward)
	private var photoMetadatas: [PhotoMetadata]
	// TODO: Filter
	
	@State private var gridScrollPosition = ScrollPosition()
	@State private var isPaletteSheetShown = false
	@State private var searchText = ""
	// TODO: Actual search with debounce?
	
	var body: some View {
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
					navState.photoDetailRequest = PhotoDetailRequest(
						id: photoMetadata.id,
						photoMetadatas: photoMetadatas.reversed(),
						namespace: galleryNamespace,
						scrollPosition: $gridScrollPosition
					)
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
			
			DefaultToolbarItem(kind: .search, placement: .bottomBar)
			
			ToolbarSpacer(.flexible, placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Button {
					isPaletteSheetShown = true
				} label: {
					HStack {
						Image(systemName: "swatchpalette.fill")
							.symbolRenderingMode(.palette)
							.foregroundStyle(
								.red,
								.green,
								.blue
							)
						
						Text("Color Collections")
							.font(.title3)
							.bold()
					}
					.padding()
				}
				.matchedTransitionSource(id: "sheetSource", in: galleryNamespace)
			}
		}
		.sheet(isPresented: $isPaletteSheetShown) {
			CollectionSheetView()
				.presentationDetents([.medium, .large])
				.presentationDragIndicator(.visible)
				.navigationTransition(.zoom(sourceID: "sheetSource", in: galleryNamespace))
		}
		.searchable(text: $searchText, placement: .toolbar, prompt: "Search by color or hex...")
		.searchToolbarBehavior(.minimize)
	}
}

#Preview {
	NavigationStack {
		GalleryView()
	}
}
