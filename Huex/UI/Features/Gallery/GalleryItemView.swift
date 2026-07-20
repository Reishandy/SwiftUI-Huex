//
//  GalleryItemView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI
import SwiftData

struct GalleryItemView: View {
	let photoMetadata: PhotoMetadata
	
	@Binding var isSelect: Bool
	@Binding var selectedPhotos: Set<PhotoMetadata.ID>
	let openDetailAction: () -> Void
	
	private var isSelected: Bool {
		selectedPhotos.contains(photoMetadata.id)
	}
	
	var body: some View {
		ZStack(alignment: .bottomLeading) {
			Color.clear
				.aspectRatio(1, contentMode: .fit)
				.overlay {
					PhotoView(
						photoMetadata: photoMetadata,
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
		.onTapGesture {
			if isSelect {
				withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
					if isSelected {
						selectedPhotos.remove(photoMetadata.id)
					} else {
						selectedPhotos.insert(photoMetadata.id)
					}
				}
			} else {
				openDetailAction()
			}
		}
		.onLongPressGesture {
			if !isSelect {
				withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
					isSelect = true
					selectedPhotos = [photoMetadata.id]
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var isSelect = true
	@Previewable @State var selectedPhotos: Set<PhotoMetadata.ID> = []
	
	GalleryItemView(
		photoMetadata: PhotoMetadata(phaccessLocalIdentifier: "preview-cell"),
		isSelect: $isSelect,
		selectedPhotos: $selectedPhotos
	) {
		print("Detail View Requested")
	}
}
