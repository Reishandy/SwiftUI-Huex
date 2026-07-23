//
//  CollectionDetailView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI
import SwiftData

struct CollectionDetailView: View {
	@Namespace private var collectionDetailNamespace
	
	@Environment(\.modelContext) private var modelContext
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	let colorBucket: ColorBucket
	
	@Query private var photoMetadatas: [PhotoMetadata]
	
	@State private var gridScrollPosition = ScrollPosition()
	@State private var isSelect = false
	@State private var selectedPhotos: Set<PhotoMetadata> = []
	@State private var activePhoto: PhotoMetadata?
	@State private var isShowingDetail = false
	@State private var isShareeSheetShown = false
	
	@State private var showDeleteAlert = false
	@State private var showReanalyzeAlert = false
	@State private var moveToBucket: ColorBucket? = nil
	
	init(colorBucket: ColorBucket) {
		self.colorBucket = colorBucket
		
		let targetRawValue = colorBucket.rawValue
		let descriptor = FetchDescriptor<PhotoMetadata>(
			predicate: #Predicate { $0.bucketRawValue == targetRawValue },
			sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
		)
		self._photoMetadatas = Query(descriptor) // TODO: Check for reversed
	}
	
	var body: some View {
		Group {
			if photoMetadatas.isEmpty {
				EmptyStateView(
					systemImage: colorBucket.symbol,
					title: "No \(colorBucket.displayName) Photos.",
					description: "Take a photo with some \(colorBucket.displayName)! or wait for the analisys process to complete"
				)
			} else {
				FlushGridView(
					photoMetadatas,
					isReversed: false,
					scrollPosition: $gridScrollPosition
				) { photoMetadata in
					PhotoCellView(
						phAsset: photoStoreManager.phAssets[photoMetadata.phaccessLocalIdentifier],
						photoMetadata: photoMetadata,
						isSelect: $isSelect,
						selectedPhotos: $selectedPhotos
					) {
						activePhoto = photoMetadata
						isShowingDetail = true
					}
					.matchedTransitionSource(id: photoMetadata.id, in: collectionDetailNamespace)
				}
			}
		}
		.navigationTitle(colorBucket.displayName)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			SelectionToolbar(
				isSelect: $isSelect,
				selectedPhotos: $selectedPhotos,
				namespace: collectionDetailNamespace,
				shouldShowSelect: !photoMetadatas.isEmpty,
				onSelectAll: {
					withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
						isSelect = true
						selectedPhotos = Set(photoMetadatas)
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
		}
		.sheet(isPresented: $isShareeSheetShown) {
			ShareSheetView(selectedPhotos: selectedPhotos.map{$0}) // TODO: Optimize?
				.presentationDetents([.large])
				.presentationDragIndicator(.visible)
				.presentationSizing(.page)
				.navigationTransition(.zoom(sourceID: "shareSheetSource", in: collectionDetailNamespace))
		}
		.navigationDestination(isPresented: $isShowingDetail) {
			if let activePhoto {
				PhotoDetailView(
					photoMetadatas: photoMetadatas,
					initialPhotoID: activePhoto.id,
					namespace: collectionDetailNamespace,
					scrollPosition: $gridScrollPosition,
					removesOnMove: true
				)
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
}

#Preview {
	NavigationStack {
		CollectionDetailView(colorBucket: .red)
			.modelContainer(PreviewData.container)
	}
	.environment(PhotoStoreManager())
}
