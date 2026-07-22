//
//  CollectionItemView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 20/07/26.
//

import SwiftUI
import SwiftData

struct CollectionItemView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	let colorBucket: ColorBucket
	
	@Query private var previewPhotos: [PhotoMetadata]
	@State private var totalCount: Int = 0
	
	init(colorBucket: ColorBucket) {
		self.colorBucket = colorBucket
		
		let targetRawValue = colorBucket.rawValue
		let descriptor = FetchDescriptor<PhotoMetadata>(
			predicate: #Predicate { $0.bucketRawValue == targetRawValue },
			sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
		)
		var limitedDescriptor = descriptor
		limitedDescriptor.fetchLimit = 1
		_previewPhotos = Query(limitedDescriptor)
	}
	
	var body: some View {
		HStack(spacing: 16) {
			Color.clear
				.aspectRatio(1, contentMode: .fit)
				.overlay {
					if let photo = previewPhotos.first {
						PhotoItemView(
							phAsset: photoStoreManager.phAssets[photo.phaccessLocalIdentifier],
							photoMetadata: photo,
							targetSize: CGSize(width: 80, height: 80),
							contentMode: .fill
						)
					} else {
						Image(systemName: colorBucket.symbol)
							.font(.largeTitle)
							.foregroundStyle(colorBucket.color)
							.shadow(radius: 4)
					}
				}
				.clipShape(RoundedRectangle(cornerRadius: 12))
				.contentShape(RoundedRectangle(cornerRadius: 12))
				.frame(width: 60, height: 60)
			
			VStack(alignment: .leading, spacing: 8) {
				HStack {
					if !previewPhotos.isEmpty {
						Image(systemName: colorBucket.symbol)
							.foregroundStyle(colorBucket.color)
							.shadow(radius: 4)
					}
					
					Text(colorBucket.displayName)
						.font(.title2)
						.bold()
				}
				
				Text(totalCount == 0 ? "Empty" : "\(totalCount) Photos")
					.foregroundStyle(.secondary)
			}
			
			Spacer()
			
			Image(systemName: "chevron.forward")
				.foregroundStyle(.secondary)
		}
		.task {
			let targetRawValue = colorBucket.rawValue
			let descriptor = FetchDescriptor<PhotoMetadata>(
				predicate: #Predicate { $0.bucketRawValue == targetRawValue }
			)
			totalCount = (try? modelContext.fetchCount(descriptor)) ?? 0
		}
	}
}

#Preview {
	CollectionItemView(colorBucket: ColorBucket.red)
		.modelContainer(PreviewData.container)
		.environment(PhotoStoreManager())
}
