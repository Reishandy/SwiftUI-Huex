//
//  PhotoFilmstripView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 18/07/26.
//

import SwiftUI
import SwiftData

struct PhotoFilmstripView: View {
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	let photoMetadatas: [PhotoMetadata]
	@Binding var activeID: PhotoMetadata.ID?
	
	@State private var localScrollID: PhotoMetadata.ID?
	@State private var hapticTrigger = false
	
	private let baseHeight: CGFloat = 40
	private let inactiveWidth: CGFloat = 20
	private let activeSize: CGFloat = 60
	
	var body: some View {
		GeometryReader { geometry in
			ScrollView(.horizontal, showsIndicators: false) {
				LazyHStack(spacing: 6) {
					ForEach(photoMetadatas) { photoMetadata in
						let isActive = localScrollID == photoMetadata.id
						
						PhotoItemView(
							phAsset: photoStoreManager.phAssets[photoMetadata.phaccessLocalIdentifier],
							photoMetadata: photoMetadata,
							targetSize: CGSize(width: 100, height: 100),
							contentMode: .fill
						)
						.frame(
							width: isActive ? activeSize : inactiveWidth,
							height: isActive ? activeSize : baseHeight
						)
						.clipShape(RoundedRectangle(cornerRadius: 6))
						.overlay(
							RoundedRectangle(cornerRadius: 6)
								.stroke(photoMetadata.bucket?.color ?? .secondary, lineWidth: 1)
								.opacity(isActive ? 1.0 : 0.6)
						)
						.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
						.id(photoMetadata.id)
						.onTapGesture {
							withAnimation {
								activeID = photoMetadata.id
							}
						}
					}
				}
				.scrollTargetLayout()
			}
			.contentMargins(.horizontal, max(0, (geometry.size.width - activeSize) / 2), for: .scrollContent)
			.scrollIndicators(.hidden)
			.scrollTargetBehavior(.viewAligned)
			.scrollPosition(id: $localScrollID, anchor: .center)
			.onChange(of: activeID) { _, newID in
				guard localScrollID != newID else { return }
				withAnimation(.easeInOut) {
					localScrollID = newID
				}
			}
			.onChange(of: localScrollID) { _, newID in
				guard let newID, activeID != newID else { return }
				activeID = newID
				
				hapticTrigger.toggle()
			}
			.task {
				try? await Task.sleep(for: .milliseconds(50))
				if localScrollID == nil {
					localScrollID = activeID
				}
			}
			.sensoryFeedback(.impact, trigger: hapticTrigger)
		}
		.frame(height: activeSize + 20)
	}
}

#Preview {
	PhotoFilmstripView(
		photoMetadatas: [PhotoMetadata(phaccessLocalIdentifier: "preview"), PhotoMetadata(phaccessLocalIdentifier: "preview")],
		activeID: .constant(PhotoMetadata(phaccessLocalIdentifier: "preview").id)
	)
	.environment(PhotoStoreManager())
}
