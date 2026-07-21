//
//  GalleryView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import SwiftUI
import SwiftData
import Photos

struct GalleryView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	@Query(sort: \PhotoMetadata.timestamp, order: .reverse)
	private var photoMetadatas: [PhotoMetadata]
	
	@State private var scrollPosition = ScrollPosition()
	@State private var searchText = ""
	@State private var debouncedSearchText = ""
	@State private var isSelect = false
	@State private var selectedPhotos: Set<PhotoMetadata> = []
	@State private var activePhoto: PhotoMetadata?
	
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
	
	var body: some View {
		Group {
			if filteredPhotos.isEmpty {
				EmpyStateView(
					systemImage: "photo.badge.magnifyingglass.fill",
					title: "No Photo Found",
					description: "We couln't find any photos, check your search or take new photos!"
				)
			} else {
				FlushGridView(
					filteredPhotos,
					isReversed: true,
					scrollPosition: $scrollPosition
				) { photoMetadata in
					PhotoCellView(
						phAsset: photoStoreManager.phAssets[photoMetadata.phaccessLocalIdentifier],
						photoMetadata: photoMetadata,
						isSelect: $isSelect,
						selectedPhotos: $selectedPhotos
					) {
						// TODO: Detail view
					}
				}
			}
		}
		.toolbar { galleryToolbar }
		.navigationDestination(item: $activePhoto) { photo in
			// TODO: Photo Detail View
		}
		.searchable(text: $searchText, placement: .toolbar, prompt: "Search by color or hex...")
		.searchToolbarBehavior(.minimize)
		.task(id: searchText) {
			try? await Task.sleep(for: .milliseconds(300))
			
			withAnimation(.snappy) {
				debouncedSearchText = searchText
			}
		}
		.sensoryFeedback(.impact, trigger: isSelect)
	}
	
	@ToolbarContentBuilder
	private var galleryToolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			GalleryTitleView(
				isAnalyzing: photoStoreManager.isAnalyzing,
				totalImages: String(photoMetadatas.count),
				processedImages: String(photoMetadatas.filter { $0.bucketRawValue != nil }.count)
			)
		}
		.sharedBackgroundVisibility(.hidden)
		
		if isSelect {
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button("Select All", systemImage: "square.grid.2x2.fill") {
						withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
							isSelect = true
							selectedPhotos = Set(filteredPhotos)
						}
					}
					.disabled(!selectedPhotos.isEmpty)
					
					Button("Select None", systemImage: "square.grid.2x2") {
						withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
							selectedPhotos = []
						}
					}
					.disabled(selectedPhotos.isEmpty)
					
					Divider()
					
					Button("Reanalyze", systemImage: "arrow.2.squarepath") {
						for selectedPhoto in selectedPhotos {
							selectedPhoto.bucketRawValue = nil
							selectedPhoto.swatches = nil
						}
						
						try? modelContext.save()
						Task {
							try? await photoStoreManager.analyzePhotos()
						}
					}
					.disabled(selectedPhotos.isEmpty)
					
					Button("Delete", systemImage: "trash", role: .destructive) {
						Task {
							await deletePhotos(localIdentifiers: selectedPhotos.map { $0.phaccessLocalIdentifier })
						}
					}
					.disabled(selectedPhotos.isEmpty)
				} label: {
					Image(systemName: "ellipsis")
				}
			}
		}
		
		ToolbarSpacer(placement: .topBarTrailing)
		
		if !photoMetadatas.isEmpty {
			ToolbarItem(placement: .topBarTrailing) {
				if isSelect {
					Button("Done", systemImage: "checkmark") {
						withAnimation {
							isSelect = false
						}
						selectedPhotos = []
					}
					.buttonStyle(.glassProminent)
				} else {
					Button("Select") {
						withAnimation {
							isSelect = true
						}
					}
				}
			}
		}
		
		if isSelect {
			ToolbarItem(placement: .bottomBar) {
				// TODO: Share
				Button("Share", systemImage: "square.and.arrow.up") {
					
				}
				.disabled(selectedPhotos.isEmpty)
			}
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Text("\(selectedPhotos.count) Photo\(selectedPhotos.count > 1 ? "s" : "") Selected")
					.bold()
					.fixedSize()
			}
			.sharedBackgroundVisibility(.hidden)
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				// TODO: Move picker?
				Button("Move", systemImage: "arrow.forward.folder") {
					
				}
				.disabled(selectedPhotos.isEmpty)
			}
		} else {
			DefaultToolbarItem(kind: .search, placement: .bottomBar)
			
			ToolbarSpacer(.flexible, placement: .bottomBar)
		}
	}
}

#Preview {
	NavigationStack {
		GalleryView()
			.modelContainer(PreviewData.container)
			.environment(PhotoStoreManager())
	}
}
