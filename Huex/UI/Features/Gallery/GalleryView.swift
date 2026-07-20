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
	
	@Query(sort: \PhotoMetadata.timestamp, order: .reverse)
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
	@State private var isCollectionSheetShown = false
	@State private var searchText = ""
	@State private var debouncedSearchText = ""
	@State private var isSelect = false
	@State private var selectedPhotos: Set<PhotoMetadata.ID> = [] // TODO: Use ID or whole?
	
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
					GalleryCellView(
						photoMetadata: photoMetadata,
						isSelect: $isSelect,
						selectedPhotos: $selectedPhotos
					) {
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
					totalImages: photoMetadatas.count,
					processedImages: photoMetadatas.filter { $0.bucket != nil }.count,
					isProcessing: false // TODO: Expose is running
				)
			}
			.sharedBackgroundVisibility(.hidden)
			
			if isSelect {
				ToolbarItem(placement: .topBarTrailing) {
					// TODO: Actions
					Menu {
						Button("Select All", systemImage: "square.grid.2x2.fill") {
							withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
								isSelect = true
								selectedPhotos = Set(photoMetadatas.map { $0.id })
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
							
						}
						.disabled(selectedPhotos.isEmpty)
						
						Button("Delete", systemImage: "trash", role: .destructive) {
							
						}
						.disabled(selectedPhotos.isEmpty)
					} label: {
						Image(systemName: "ellipsis")
					}
				}
			}
			
			ToolbarSpacer(placement: .topBarTrailing)
			
			ToolbarItem(placement: .topBarTrailing) {
				if isSelect {
					Button("Done", systemImage: "checkmark") {
						withAnimation {
							isSelect = false
							selectedPhotos = []
						}
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
					// TODO: Move
					Button("Move", systemImage: "arrow.forward.folder") {
						
					}
					.disabled(selectedPhotos.isEmpty)
				}
			} else {
				DefaultToolbarItem(kind: .search, placement: .bottomBar)
				
				ToolbarSpacer(.flexible, placement: .bottomBar)
				
				ToolbarItem(placement: .bottomBar) {
					Button {
						isCollectionSheetShown = true
					} label: {
						HStack {
							Image(systemName: "paintpalette.fill")
								.symbolRenderingMode(.multicolor)
							
							Text("Color Collections")
								.font(.title3)
								.bold()
						}
						.padding()
					}
					.matchedTransitionSource(id: "sheetSource", in: galleryNamespace)
					.gesture(
						DragGesture()
							.onEnded { value in
								if value.translation.height < -5 {
									isCollectionSheetShown = true
								}
							}
					)
				}
			}
		}
		.sheet(isPresented: $isCollectionSheetShown) {
			CollectionSheetView()
				.presentationDetents([.medium, .large])
				.presentationDragIndicator(.visible)
				.presentationSizing(.page)
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
		.sensoryFeedback(.impact, trigger: isSelect)
	}
}

#Preview {
	NavigationStack {
		GalleryView()
	}
}
