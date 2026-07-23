//
//  ShareSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

import SwiftUI
import SwiftData

struct ShareSheetView: View {
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	let selectedPhotos: [PhotoMetadata]
	
	@State private var selectedMode: ShareMode = .minimal
	
	// TODO: Dismiss when sharing is done
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
										phAsset: photoStoreManager.phAssets[photo.phaccessLocalIdentifier],
										photoMetadata: photo,
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
			.scrollTargetBehavior(.paging)
			.navigationTitle("Share\(selectedPhotos.count > 1 ? " \(selectedPhotos.count) photos" : "")")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Image(systemName: "square.and.arrow.up")
					// TODO: Sharelink
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
