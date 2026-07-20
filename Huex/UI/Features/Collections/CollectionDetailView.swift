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
	
	let colorBucket: ColorBucket
	
	@Query private var photoMetadatas: [PhotoMetadata]
	
	@State private var gridScrollPosition = ScrollPosition()
	@State private var isSelect = false
	@State private var selectedPhotos: Set<PhotoMetadata.ID> = []
	@State private var activePhoto: PhotoMetadata?
	@State private var isShowingDetail = false // Workaround since this is nested
	
	init(colorBucket: ColorBucket) {
		self.colorBucket = colorBucket
		
		let targetRawValue = colorBucket.rawValue
		let descriptor = FetchDescriptor<PhotoMetadata>(
			predicate: #Predicate { $0.bucketRawValue == targetRawValue },
			sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
		)
		self._photoMetadatas = Query(descriptor)
	}
	
	// TODO: Check for reversed
	var body: some View {
		Group {
			if photoMetadatas.isEmpty {
				EmpyStateView(
					systemImage: colorBucket.symbol,
					title: "No \(colorBucket.displayName) Photos.",
					description: "Take some \(colorBucket.displayName) photos! or wait for the analisys process to complete"
				)
			} else {
				FlushGridView(
					photoMetadatas,
					isReversed: false,
					scrollPosition: $gridScrollPosition
				) { photoMetadata in
					PhotoCellView(
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
			}
		}
		.navigationDestination(isPresented: $isShowingDetail) {
			if let activePhoto {
				PhotoDetailView(
					photoMetadatas: photoMetadatas,
					initialPhotoID: activePhoto.id,
					namespace: collectionDetailNamespace,
					gridScrollPosition: $gridScrollPosition
				)
			}
		}
		.sensoryFeedback(.impact, trigger: isSelect)
	}
}

#Preview {
	NavigationStack {
		CollectionDetailView(colorBucket: .red)
			.modelContainer(PreviewData.container)
	}
}
