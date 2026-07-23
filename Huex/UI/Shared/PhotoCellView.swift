//
//  PhotoCellView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import SwiftUI
import SwiftData
import Photos

struct PhotoCellView: View {
	let phAsset: PHAsset?
	let photoMetadata: PhotoMetadata
	
	@Binding var isSelect: Bool
	@Binding var selectedPhotos: Set<PhotoMetadata>
	let openDetailAction: () -> Void
	
	private var isSelected: Bool {
		selectedPhotos.contains(photoMetadata)
	}
	
	var body: some View {
		ZStack(alignment: .bottomLeading) {
			Color.clear
				.aspectRatio(1, contentMode: .fit)
				.overlay {
					PhotoItemView(
						phAsset: phAsset,
						targetSize: CGSize(width: 300, height: 300),
						contentMode: .fill
					)
				}
				.clipShape(RoundedRectangle(cornerRadius: 4))
				.contentShape(RoundedRectangle(cornerRadius: 4))
			
			Image(systemName: photoMetadata.bucket?.symbol ?? "questionmark")
				.foregroundStyle(photoMetadata.bucket?.color ?? .secondary)
				.padding(8)
				.shadow(radius: 4)
				.glassEffect(.regular, in: Circle())
				.padding(6)
			
			if isSelect {
				Color.black
					.opacity(isSelected ? 0.4 : 0.0)
					.clipShape(RoundedRectangle(cornerRadius: 4))
					.allowsHitTesting(false)
				
				if isSelected {
					VStack {
						Spacer()
						
						HStack {
							Spacer()
							
							Image(systemName: "checkmark.circle.fill")
								.font(.title2)
								.symbolRenderingMode(.palette)
								.foregroundStyle(
									.white,
									.blue
								)
								.padding(8)
								.shadow(radius: 4)
						}
					}
				}
			}
		}
		.animation(.default, value: photoMetadata.bucket)
		.gesture(
			LongPressGesture(minimumDuration: 0.2)
				.onEnded { _ in
					if !isSelect {
						withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
							isSelect = true
							selectedPhotos = [photoMetadata]
						}
					}
				}
				.exclusively(
					before: TapGesture()
						.onEnded {
							if isSelect {
								withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
									if isSelected {
										selectedPhotos.remove(photoMetadata)
									} else {
										selectedPhotos.insert(photoMetadata)
									}
								}
							} else {
								openDetailAction()
							}
						}
				)
		)
	}
}

#Preview {
	@Previewable @State var isSelect = true
	@Previewable @State var selectedPhotos: Set<PhotoMetadata> = []
	
	PhotoCellView(
		phAsset: PHAsset(),
		photoMetadata: PhotoMetadata(phaccessLocalIdentifier: "preview-cell"),
		isSelect: $isSelect,
		selectedPhotos: $selectedPhotos
	) {
		print("Detail View Requested")
	}
}
