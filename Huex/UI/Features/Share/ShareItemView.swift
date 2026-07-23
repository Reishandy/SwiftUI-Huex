//
//  ShareItemView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

import SwiftUI
import Photos

struct ShareItemView: View {
	let image: UIImage?
	let bucketDisplayName: String
	let bucketSymbol: String
	let bucketColor: Color
	let swatches: [Swatch]
	let topPalette: [Swatch]
	let shareMode: ShareMode
	
	private var sortedSwatches: [Swatch] {
		swatches.sorted { $0.weight > $1.weight }
	}
	
	var body: some View {
		VStack {
			Spacer(minLength: 0)
			
			VStack(spacing: 0) {
				if let image {
					Image(uiImage: image)
						.resizable()
						.aspectRatio(contentMode: .fit)
				} else {
					Rectangle()
						.fill(Color.secondary.opacity(0.1))
						.aspectRatio(3/4, contentMode: .fit)
						.overlay { Image(systemName: "photo.trianglebadge.exclamationmark") }
				}
				
				if shareMode != .clean {
					metadataView
				}
			}
			
			Spacer(minLength: 0)
		}
	}
	
	@ViewBuilder
	private var metadataView: some View {
		VStack {
			HStack {
				HStack(spacing: 2) {
					if shareMode == .detailed {
						Image("icon")
							.resizable()
							.frame(width: 22, height: 22)
					}
					
					Text("Huex")
						.font(.system(.footnote, design: .rounded))
						.bold()
						.lineLimit(1)
						.minimumScaleFactor(0.5)
						.foregroundStyle(.black)
						.opacity(shareMode == .detailed ? 1 : 0.5)
				}
				.geometryGroup()
				
				Spacer(minLength: 8)
				
				if shareMode == .detailed {
					HStack(spacing: 6) {
						Text(bucketDisplayName)
							.font(.system(.footnote, design: .rounded))
							.lineLimit(1)
							.minimumScaleFactor(0.5)
							.foregroundStyle(.black)
						
						Image(systemName: bucketSymbol)
							.foregroundStyle(bucketColor)
							.font(.system(.footnote, design: .rounded))
							.lineLimit(1)
							.minimumScaleFactor(0.5)
							.shadow(radius: 2)
					}
				} else {
					HStack(spacing: 3) {
						ForEach(topPalette.prefix(5)) { swatch in
							RoundedRectangle(cornerRadius: 4)
								.fill(Color(UIColor(hex: swatch.hex) ?? .lightGray))
								.frame(width: 14, height: 14)
								.shadow(radius: 2)
						}
					}
				}
			}
			
			if shareMode == .detailed {
				let maxWeight = sortedSwatches.first?.weight ?? 0
				
				VStack(spacing: 4) {
					ForEach(sortedSwatches) { swatch in
						SharePaletteItemView(swatch: swatch, maxWeight: maxWeight)
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
				image: nil,
				bucketDisplayName: "White",
				bucketSymbol: "paintpalette",
				bucketColor: .white,
				swatches: PreviewData.sampleSwatches,
				topPalette: PreviewData.sampleSwatches,
				shareMode: .minimal
			)
			
			ShareItemView(
				image: nil,
				bucketDisplayName: "Red",
				bucketSymbol: "paintpalette",
				bucketColor: .red,
				swatches: PreviewData.sampleSwatches,
				topPalette: PreviewData.sampleSwatches,
				shareMode: .detailed
			)
		}
		.padding(24)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.blue)
	}
}
