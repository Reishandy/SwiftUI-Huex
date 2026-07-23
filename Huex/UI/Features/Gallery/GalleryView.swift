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
	@Namespace private var galleryNamespace
	
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
	@State private var isCollectionSheetShown = false
	@State private var isShareeSheetShown = false
	@State private var selectedBucket: ColorBucket?
	
	@State private var showDeleteAlert = false
	@State private var showReanalyzeAlert = false
	@State private var moveToBucket: ColorBucket? = nil
	
	var filteredPhotos: [PhotoMetadata] {
		guard !debouncedSearchText.isEmpty else {
			return photoMetadatas
		}
		
		let query = debouncedSearchText.lowercased()
		
		return photoMetadatas.filter { photo in
			// TODO: Decide if all colors or some treshold weight for the name
			return photo.swatches.contains { swatch in
				let matchesHex = swatch.hex.lowercased().contains(query)
				let matchesName = swatch.name?.lowercased().contains(query) ?? false
				
				return matchesHex || matchesName
			}
		}
	}
	
	var body: some View {
		Group {
			if filteredPhotos.isEmpty {
				EmptyStateView(
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
						activePhoto = photoMetadata
					}
					.matchedTransitionSource(id: photoMetadata.id, in: galleryNamespace)
				}
			}
		}
		.toolbar { galleryToolbar }
		.sheet(isPresented: $isCollectionSheetShown) {
			CollectionSheetView(selectedBucket: $selectedBucket)
				.presentationDetents([.medium, .large])
				.presentationDragIndicator(.visible)
				.presentationSizing(.page)
				.presentationContentInteraction(.resizes)
				.navigationTransition(.zoom(sourceID: "sheetSource", in: galleryNamespace))
		}
		.sheet(isPresented: $isShareeSheetShown) {
			ShareSheetView(selectedPhotos: selectedPhotos.map{$0}.reversed()) // TODO: Optimize?
				.presentationDetents([.large])
				.presentationDragIndicator(.visible)
				.presentationSizing(.page)
				.navigationTransition(.zoom(sourceID: "shareSheetSource", in: galleryNamespace))
		}
		.navigationDestination(item: $activePhoto) { photo in
			PhotoDetailView(
				photoMetadatas: filteredPhotos.reversed(),
				initialPhotoID: photo.id,
				namespace: galleryNamespace,
				scrollPosition: $scrollPosition
			)
		}
		.navigationDestination(item: $selectedBucket) { bucket in
			CollectionDetailView(colorBucket: bucket)
		}
		.searchable(text: $searchText, placement: .toolbar, prompt: "Search by color or hex...")
		.searchToolbarBehavior(.minimize)
		.task(id: searchText) {
			try? await Task.sleep(for: .milliseconds(300))
			
			withAnimation(.snappy) {
				debouncedSearchText = searchText
			}
		}
		.photoActionAlerts(
			selectedCount: selectedPhotos.count,
			showDeleteAlert: $showDeleteAlert,
			showReanalyzeAlert: $showReanalyzeAlert,
			moveToBucket: $moveToBucket,
			onDelete: {
				Task {
					let identifiers = selectedPhotos.map { $0.phaccessLocalIdentifier }
					
					let success = await deletePhotos(localIdentifiers: identifiers)
					if success {
						withAnimation {
							isSelect = false
							selectedPhotos.removeAll()
						}
					}
				}
			},
			onReanalyze: {
				withAnimation {
					for photo in selectedPhotos {
						photo.bucketRawValue = nil
						photo.swatches = []
					}
					
					try? modelContext.save()
					
					Task {
						try? await photoStoreManager.analyzePhotos()
					}
					
					isSelect = false
					selectedPhotos.removeAll()
				}
			},
			onMove: {
				withAnimation {
					if let targetBucket = moveToBucket {
						for photo in selectedPhotos {
							photo.bucketRawValue = targetBucket.rawValue
						}
						
						try? modelContext.save()
						
						isSelect = false
						selectedPhotos.removeAll()
					}
				}
			}
		)
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
		
		SelectionToolbar(
			isSelect: $isSelect,
			selectedPhotos: $selectedPhotos,
			namespace: galleryNamespace,
			shouldShowSelect: !filteredPhotos.isEmpty,
			onSelectAll: {
				withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
					isSelect = true
					selectedPhotos = Set(filteredPhotos)
				}
			},
			onDelete: {
				showDeleteAlert = true
			},
			onReanalyze: {
				showReanalyzeAlert = true
			},
			onMove: { colorBucket in
				moveToBucket = colorBucket
			},
			onShare: {
				isShareeSheetShown = true
			}
		)
		
		if !isSelect {
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
}

#Preview {
	NavigationStack {
		GalleryView()
			.modelContainer(PreviewData.container)
			.environment(PhotoStoreManager())
	}
}
