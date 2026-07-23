//
//  SharePaletteItemView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

import SwiftUI

struct SharePaletteItemView: View {
	let swatch: Swatch
	let maxWeight: Double
	var metadataScale: CGFloat = 1.0
	
	var minHeight: CGFloat = 20
	var maxHeight: CGFloat = 60
	
	private var shouldUseWhite: Bool {
		shouldUseWhiteText(onHex: swatch.hex) ?? false
	}
	
	private var normalizedWeight: Double {
		guard maxWeight > 0 else { return 0 }
		return sqrt(swatch.weight / maxWeight)
	}
	
	private var rowHeight: CGFloat {
		let scaledMin = minHeight * metadataScale
		let scaledMax = maxHeight * metadataScale
		return scaledMin + (scaledMax - scaledMin) * CGFloat(normalizedWeight)
	}
	
	private var nameFontSize: CGFloat {
		max(9 * metadataScale, min(13 * metadataScale, rowHeight * 0.32))
	}
	
	private var detailFontSize: CGFloat {
		max(8 * metadataScale, min(11 * metadataScale, rowHeight * 0.24))
	}
	
	var body: some View {
		HStack {
			Text(swatch.name ?? "Unknown")
				.font(.system(size: nameFontSize, weight: .bold, design: .rounded))
				.lineLimit(1)
				.minimumScaleFactor(0.5)
			
			Spacer(minLength: 8 * metadataScale)
			
			Text("\(swatch.weight * 100, specifier: "%.2f")%")
				.font(.system(size: detailFontSize, design: .monospaced))
				.opacity(0.6)
				.lineLimit(1)
				.minimumScaleFactor(0.5)
			
			Text(swatch.hex.uppercased())
				.font(.system(size: detailFontSize, design: .monospaced))
				.opacity(0.6)
				.lineLimit(1)
				.minimumScaleFactor(0.5)
		}
		.foregroundStyle(shouldUseWhite ? .white : .black)
		.padding(.horizontal, 8 * metadataScale)
		.frame(height: rowHeight)
		.frame(maxWidth: .infinity)
		.background(Color(UIColor(hex: swatch.hex) ?? UIColor.lightGray))
		.clipShape(RoundedRectangle(cornerRadius: 8 * metadataScale))
	}
}

#Preview {
	VStack(spacing: 4) {
		SharePaletteItemView(swatch: .make(hex: "F4F3F7", weight: 0.89), maxWeight: 0.89)
		SharePaletteItemView(swatch: .make(hex: "CECCD1", weight: 0.055), maxWeight: 0.89)
		SharePaletteItemView(swatch: .make(hex: "9A999C", weight: 0.018), maxWeight: 0.89)
		SharePaletteItemView(swatch: .make(hex: "F9974A", weight: 0.0061), maxWeight: 0.89)
		SharePaletteItemView(swatch: .make(hex: "83E0CC", weight: 0.0019), maxWeight: 0.89)
	}
	.padding()
}
