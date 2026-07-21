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
	
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	let colorBucket: ColorBucket
	
	@Query private var photoMetadatas: [PhotoMetadata]
	
	@State private var gridScrollPosition = ScrollPosition()
	@State private var isSelect = false
	@State private var selectedPhotos: Set<PhotoMetadata> = []
	@State private var activePhoto: PhotoMetadata?
	@State private var isShowingDetail = false // Workaround since this is nested
	
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
				EmpyStateView(
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
				shouldShowSelect: !photoMetadatas.isEmpty,
				onSelectAll: {
					withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
						isSelect = true
						selectedPhotos = Set(photoMetadatas)
					}
				},
				onDelete: {
					// TODO: Delete
				},
				onReanalyze: {
					// TODO: Reanalyz
				},
				onMove: {
					// TODO: Move
				}
			)
		}
		.navigationDestination(isPresented: $isShowingDetail) {
			if let activePhoto {
				PhotoDetailView(
					photoMetadatas: photoMetadatas,
					initialPhotoID: activePhoto.id,
					namespace: collectionDetailNamespace,
					scrollPosition: $gridScrollPosition
				)
			}
		}
	}
}

#Preview {
	NavigationStack {
		CollectionDetailView(colorBucket: .red)
			.modelContainer(PreviewData.container)
	}
	.environment(PhotoStoreManager())
}
