//
//  ShareItemView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

import SwiftUI
import Photos

struct ShareItemView: View {
	let phAsset: PHAsset?
	let photoMetadata: PhotoMetadata
	let shareMode: ShareMode
	
    var body: some View {
		VStack {
			Spacer(minLength: 0)
			
			VStack(spacing: 0) {
				PhotoItemView(
					phAsset: phAsset,
					targetSize: PHImageManagerMaximumSize,
					contentMode: .fit
				)
				
				if shareMode != .clean {
					metadataView
				}
			}
			.clipShape(RoundedRectangle(cornerRadius: 12))
			
			Spacer(minLength: 0)
		}
    }
	
	@ViewBuilder
	private var metadataView: some View {
		VStack {
			HStack {
				HStack {
					// TODO: App Icon
					Text("Huex")
						.font(.system(.footnote, design: .monospaced))
						.bold()
						.lineLimit(1)
						.minimumScaleFactor(0.5)
						.foregroundStyle(.black)
				}
				
				Spacer(minLength: 8)
				
				HStack(spacing: 6) {
					Text(photoMetadata.bucket?.displayName ?? "Unknown")
						.font(.system(.footnote, design: .rounded))
						.lineLimit(1)
						.minimumScaleFactor(0.5)
						.foregroundStyle(.black)
					
					Image(systemName: photoMetadata.bucket?.symbol ?? "questionmark")
						.foregroundStyle(photoMetadata.bucket?.color ?? .secondary)
						.font(.system(.footnote, design: .rounded))
						.lineLimit(1)
						.minimumScaleFactor(0.5)
						.shadow(radius: 2)
				}
			}
			
			if shareMode == .detailed {
				VStack {
					ForEach(photoMetadata.swatches) { swatch in
						SharePaletteItemView(swatch: swatch)
					}
				}
			}
		}
		.padding(8)
		.background(.white)
		.fixedSize(horizontal: false, vertical: true)
	}
}

#Preview {
	ScrollView {
		VStack(spacing: 10) {
			ShareItemView(
				phAsset: nil,
				photoMetadata: PhotoMetadata(
					phaccessLocalIdentifier: "",
					swatches: PreviewData.sampleSwatches,
					bucket: .white
				),
				shareMode: .minimal
			)
			
			ShareItemView(
				phAsset: nil,
				photoMetadata: PhotoMetadata(
					phaccessLocalIdentifier: "",
					swatches: PreviewData.sampleSwatches,
					bucket: .red
				),
				shareMode: .detailed
			)
		}
		.padding(24)
	}
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.background(.blue)
}
