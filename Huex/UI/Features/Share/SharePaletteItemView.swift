//
//  SharePaletteItemView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

import SwiftUI

struct SharePaletteItemView: View {
	let swatch: Swatch
	
	private var shouldUseWhite: Bool {
		shouldUseWhiteText(onHex: swatch.hex) ?? false
	}
	
    var body: some View {
		HStack {
			HStack {
				Text(swatch.name ?? "Unknown")
					.font(.system(.caption, design: .rounded))
					.bold()
					.lineLimit(1)
					.minimumScaleFactor(0.5)
				
				Spacer(minLength: 8)
				
				Text(swatch.hex.uppercased())
					.font(.system(.caption2, design: .monospaced))
					.opacity(0.6)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
			}
		}
		.foregroundStyle(shouldUseWhite ? .white : .black)
		.padding(8)
		.frame(maxWidth: .infinity)
		.background(Color(UIColor(hex: swatch.hex) ?? UIColor.lightGray))
		.clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    SharePaletteItemView(swatch: .make(hex: "A8F03C", weight: 0.7))
}
