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
	
	var filteredPhotos: [PhotoMetadata] {
		guard !debouncedSearchText.isEmpty else {
			return photoMetadatas
		}
		
		let query = debouncedSearchText.lowercased()
		
		return photoMetadatas.filter { photo in
			let matchesSwatch = photo.swatches?.contains { swatch in
				let matchesHex = swatch.hex.lowercased().contains(query)
				let matchesName = swatch.name?.lowercased().contains(query) ?? false
				
				return matchesHex || matchesName
			} ?? false
			
			return matchesSwatch
		}
	}
	
	@State private var gridScrollPosition = ScrollPosition()
	@State private var isPaletteSheetShown = false
	@State private var searchText = ""
	@State private var debouncedSearchText = ""
	
	var body: some View {
		Group {
			if filteredPhotos.isEmpty {
				EmpyStateView(
					systemImage: "photo.badge.magnifyingglass.fill",
					title: "No Photo Found",
					description: "We couldn't find anything for '\(searchText)'. Try a different color or hex code."
				)
			} else {
				FlushGridView(
					filteredPhotos,
					isReversed: true,
					scrollPosition: $gridScrollPosition
				) { photoMetadata in
					ZStack(alignment: .bottomLeading) {
						Color.clear
							.aspectRatio(1, contentMode: .fit)
							.overlay {
								PhotoView(photoMetadata: photoMetadata, contentMode: .fill)
							}
							.clipShape(RoundedRectangle(cornerRadius: 4))
							.contentShape(RoundedRectangle(cornerRadius: 4))
						
						Image(systemName: photoMetadata.bucket?.symbol ?? "questionmark")
							.foregroundStyle(photoMetadata.bucket?.color ?? .secondary)
							.padding(8)
							.shadow(radius: 4)
							.glassEffect(.regular, in: Circle())
							.padding(6)
					}
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
			}
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
		.task(id: searchText) {
			try? await Task.sleep(for: .milliseconds(300))
			
			withAnimation(.snappy) {
				debouncedSearchText = searchText
			}
		}
	}
}

#Preview {
	NavigationStack {
		GalleryView()
	}
}
