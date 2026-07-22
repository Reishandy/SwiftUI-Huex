//
//  PaletteStripView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 22/07/26.
//

import SwiftUI

struct PaletteStripView: View {
	let swatches: [Swatch]
	
	var body: some View {
		GeometryReader { geometry in
			let sortedSwatches = swatches.sorted { $0.weight > $1.weight }
			
			let totalWeight = max(sortedSwatches.reduce(0) { $0 + $1.weight }, .leastNormalMagnitude)
			
			HStack(spacing: 0) {
				ForEach(sortedSwatches) { swatch in
					let segmentWidth = geometry.size.width * CGFloat(swatch.weight / totalWeight)
					
					Color(UIColor(hex: swatch.hex) ?? .lightGray)
						.frame(width: segmentWidth)
				}
			}
			.clipShape(Capsule())
		}
		.frame(height: 16)
	}
}

#Preview {
	VStack(spacing: 40) {
		PaletteStripView(swatches: PreviewData.sampleSwatches)
			.padding(.horizontal)
		
		PaletteStripView(swatches: [
			.make(hex: "FFCC00", weight: 0.1),
			.make(hex: "FF3B30", weight: 0.6),
			.make(hex: "007AFF", weight: 0.3)
		])
		.padding(.horizontal)
		.frame(height: 24)
	}
}
