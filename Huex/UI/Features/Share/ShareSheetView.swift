//
//  ShareSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

import SwiftUI
import SwiftData
import Photos

struct ShareSheetView: View {
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	let selectedPhotos: [PhotoMetadata]
	
	@State private var selectedMode: ShareMode = .minimal
	@State private var loadedImages: [String: UIImage] = [:]
	
	private var allImagesLoaded: Bool {
		selectedPhotos.allSatisfy { loadedImages[$0.phaccessLocalIdentifier] != nil }
	}
	
	private var sharablePhotos: [SharablePhoto] {
		selectedPhotos.map { photo in
			SharablePhoto(
				id: photo.phaccessLocalIdentifier,
				mode: selectedMode,
				bucketDisplayName: photo.bucket?.displayName ?? "Unknown",
				bucketSymbol: photo.bucket?.symbol ?? "questionmark",
				bucketColor: photo.bucket?.color ?? .secondary,
				swatches: photo.swatches,
				topPalette: photo.topPalette
			)
		}
	}
	
    var body: some View {
		NavigationStack {
			ScrollView(.horizontal, showsIndicators: false) {
				LazyHStack(spacing: 0) {
					ForEach(selectedPhotos) { photo in
						GeometryReader { geometry in
							ScrollView(.vertical, showsIndicators: false) {
								VStack {
									Spacer()
									
									ShareItemView(
										image: loadedImages[photo.phaccessLocalIdentifier],
										bucketDisplayName: photo.bucket?.displayName ?? "Unknown",
										bucketSymbol: photo.bucket?.symbol ?? "questionmark",
										bucketColor: photo.bucket?.color ?? .secondary,
										swatches: photo.swatches,
										topPalette: photo.topPalette,
										shareMode: selectedMode
									)
									.padding(.horizontal, 20)
									
									Spacer()
								}
								.frame(minHeight: geometry.size.height)
							}
						}
						.containerRelativeFrame(.horizontal)
					}
				}
				.scrollTargetLayout()
			}
			.scrollIndicators(.visible, axes: .horizontal)
			.scrollTargetBehavior(.paging)
			.navigationTitle("Share\(selectedPhotos.count > 1 ? " \(selectedPhotos.count) photos" : "")")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					if allImagesLoaded {
						ShareLink(items: sharablePhotos, preview: { item in
							SharePreview("1 Image", image: Image(systemName: "photo"))
						}) {
							Image(systemName: "square.and.arrow.up")
						}
					} else {
						ProgressView()
					}
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					Menu {
						Picker("Share Mode", selection: $selectedMode) {
							ForEach(ShareMode.allCases) { mode in
								Text(mode.rawValue).tag(mode)
							}
						}
						.labelsVisibility(.visible)
					} label: {
						Image(systemName: "slider.horizontal.3")
					}
				}
			}
			.task {
				for photo in selectedPhotos {
					guard loadedImages[photo.phaccessLocalIdentifier] == nil,
						  let asset = photoStoreManager.phAssets[photo.phaccessLocalIdentifier] else { continue }
					loadedImages[photo.phaccessLocalIdentifier] = await fetchImage(asset: asset, targetSize: PHImageManagerMaximumSize)
				}
			}
			.animation(.default, value: selectedMode)
		}
    }
}

#Preview {
	let mockContainer = PreviewData.container
	
	let fetchDescriptor = FetchDescriptor<PhotoMetadata>()
	let allMockPhotos = (try? mockContainer.mainContext.fetch(fetchDescriptor)) ?? []
	
	let samplePhotos = Array(allMockPhotos.prefix(3))
	
	return Text("View")
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.blue)
		.sheet(isPresented: .constant(true)) {
			ShareSheetView(selectedPhotos: samplePhotos)
				.presentationDetents([.large])
				.environment(PhotoStoreManager())
				.modelContainer(mockContainer)
		}
}
