//
//  PhotoDetailView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import Photos

struct PhotoDetailView: View {
	@Environment(\.dismiss) private var dismiss
	
	let photoMetadata: PhotoMetadata
	
	// TODO: Swipeable photos
	var body: some View {
		NavigationStack {
			// TODO: Drag, zoom, etc
			PhotoView(
				photoMetadata: photoMetadata,
				targetSize: PHImageManagerMaximumSize,
				contentMode: .fit
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.contentShape(Rectangle())
			.ignoresSafeArea()
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "chevron.backward")
					}
				}
			}
		}
	}
}

#Preview {
	PhotoDetailView(photoMetadata: PhotoMetadata(phaccessLocalIdentifier: "preview-1"))
}
