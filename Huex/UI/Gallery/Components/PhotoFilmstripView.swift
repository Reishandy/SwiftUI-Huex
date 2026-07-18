//
//  PhotoFilmstripView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 18/07/26.
//

import SwiftUI
import SwiftData

struct PhotoFilmstripView: View {
	let photoMetadatas: [PhotoMetadata]
	@Binding var currentPhoto: PhotoMetadata
	
	@State private var scrollPosition: PhotoMetadata.ID?
	
	private let itemSize: CGFloat = 40
	
	var body: some View {
		GeometryReader { geometry in
			ScrollView(.horizontal, showsIndicators: false) {
				LazyHStack(spacing: 12) {
					ForEach(photoMetadatas) { photoMetadata in
						PhotoView(
							photoMetadata: photoMetadata,
							targetSize: CGSize(width: 100, height: 100),
							contentMode: .fill
						)
						.frame(width: itemSize, height: itemSize)
						.clipShape(RoundedRectangle(cornerRadius: 6))
						.scrollTransition(.interactive, axis: .horizontal) { content, phase in
							content
								.scaleEffect(phase.isIdentity ? 1.5 : 1.0)
								.opacity(phase.isIdentity ? 1 : 0.6)
						}
						.id(photoMetadata.id)
						.onTapGesture {
							withAnimation(.easeInOut) {
								currentPhoto = photoMetadata
							}
						}
					}
				}
				.scrollTargetLayout()
			}
			.contentMargins(.horizontal, max(0, (geometry.size.width - itemSize) / 2), for: .scrollContent)
			.scrollIndicators(.hidden)
			.scrollTargetBehavior(.viewAligned)
			.scrollPosition(id: $scrollPosition, anchor: .center)
			.onChange(of: scrollPosition) { _, newId in
				guard let newId,
					  newId != currentPhoto.id,
					  let match = photoMetadatas.first(where: { $0.id == newId }) else { return }
				currentPhoto = match
			}
			.onChange(of: currentPhoto) { _, newPhoto in
				guard scrollPosition != newPhoto.id else { return }
				withAnimation(.easeInOut) {
					scrollPosition = newPhoto.id
				}
			}
			.onAppear {
				scrollPosition = currentPhoto.id
			}
			.sensoryFeedback(.impact, trigger: scrollPosition)
		}
		.frame(height: itemSize + 20)
	}
}

#Preview {
    PhotoFilmstripView(
		photoMetadatas: [PhotoMetadata(phaccessLocalIdentifier: "preview"), PhotoMetadata(phaccessLocalIdentifier: "preview")],
		currentPhoto: .constant(PhotoMetadata(phaccessLocalIdentifier: "preview"))
	)
}
