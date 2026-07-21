//
//  GalleryTitleView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import SwiftUI

struct GalleryTitleView: View {
	let isAnalyzing: Bool
	let totalImages: String
	let processedImages: String
	
    var body: some View {
		VStack(alignment: .leading) {
			Text("Gallery")
				.font(.largeTitle)
				.bold()
				.fixedSize()
			
			HStack {
				Text(isAnalyzing ? "Analyzing \(processedImages)/\(totalImages)" : "\(totalImages) Images")
					.foregroundStyle(.secondary)
					.fixedSize()
					.contentTransition(.interpolate)
				
				if isAnalyzing {
					Image(systemName: "square.grid.2x2")
						.foregroundStyle(.secondary)
						.font(.caption)
						.symbolEffect(.bounce.down, options: .repeat(.periodic(delay: 0.5)))
						.transition(.opacity.combined(with: .scale))
				}
			}
			.animation(.easeInOut, value: isAnalyzing)
		}
		.padding(.top)
    }
}

#Preview {
    GalleryTitleView(
		isAnalyzing: false, totalImages: "1000", processedImages: "100"
	)
}
